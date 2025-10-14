package apis

import (
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"slices"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

type EnrollmentRequest struct {
	UserID       string `json:"id_user" validate:"required"`
	TournamentID string `json:"id_tournament" validate:"required"`
	ListType     string `json:"list_type" validate:"required"`
	FromOwner    *bool  `json:"from_owner" validate:"required"`
}

type UserDetailSucessResponse struct {
	Found                bool   `json:"found"`
	Enrolled             bool   `json:"enrolled"`
	Eligible             bool   `json:"eligible"`
	Name                 string `json:"name"`
	Surname              string `json:"surname"`
	Username             string `json:"username"`
	ListType             string `json:"list_type"`
	NotEligibilityReason string `json:"not_eligibility_reason"`
}

// Validation context to track request state
type ValidationContext struct {
	App             *pocketbase.PocketBase
	RequesterUserID string
	Data            EnrollmentRequest
	Tournament      *core.Record
	StartTime       time.Time
}

const (
	enrollmentListRegistered    = "registered"
	enrollmentListWaiting       = "waiting"
	enrollmentListPreRegistered = "preregistered"
)

func GetUserInfoToEnrollAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.POST("/api/tournamentManager/getUserInfo", func(e *core.RequestEvent) error {
			// Common validation pipeline
			ctx, validationErr := validateEnrollmentRequest(e, app)
			if validationErr != nil {
				return sendErrorResponse(e, validationErr)
			}

			userDetailSucessResponse, err := gatherUserDetailsForEnrollment(app, ctx.Tournament, ctx.Data.ListType, ctx.Data.UserID)
			if err != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "USER_DETAILS_RETRIEVAL_FAILED",
					Message: err.Error(),
					Code:    http.StatusBadRequest,
				})
			}

			return e.JSON(http.StatusOK, userDetailSucessResponse)

		}).Bind(apis.RequireAuth())

		return se.Next()
	})
}

func DeleteTournamentEnrollmentAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.POST("/api/tournamentManager/delete", func(e *core.RequestEvent) error {
			// Common validation pipeline
			ctx, validationErr := validateEnrollmentRequest(e, app)
			if validationErr != nil {
				return sendErrorResponse(e, validationErr)
			}

			//verify elegibility of user in tournament
			err2 := checkUserElegibilityForDeletion(app, ctx.Tournament, ctx.Data.ListType, ctx.Data.UserID)
			if err2 != nil {
				return e.JSON(http.StatusForbidden, ErrorResponse{
					Error:   "USER_ELIGIBILITY_FAILED",
					Message: err2.Error(),
					Code:    http.StatusForbidden,
				})
			}

			// Execute update in enrollment with check on capacity if needed
			err3 := executeDBEnrollmentDeletion(app, ctx.Data.UserID, ctx.Data.TournamentID, ctx.Data.ListType)
			if err3 != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "ENROLLMENT_DELETION_FAILED",
					Message: err3.Error(),
					Code:    http.StatusBadRequest,
				})
			}

			return e.JSON(http.StatusOK, SuccessResponse{
				Success: true,
				Message: "User deleted from tournament enrollment successfully",
				Data: map[string]string{
					"user_id":       ctx.Data.UserID,
					"tournament_id": ctx.Data.TournamentID,
					"list_type":     ctx.Data.ListType,
				},
			})
		}).Bind(apis.RequireAuth())

		return se.Next()
	})
}

func RegisterTournamentEnrollmentAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.POST("/api/tournamentManager/enroll", func(e *core.RequestEvent) error {
			// Common validation pipeline
			ctx, validationErr := validateEnrollmentRequest(e, app)
			if validationErr != nil {
				return sendErrorResponse(e, validationErr)
			}
			// Log performance if needed (optional, can be made configurable)
			app.Logger().Info(fmt.Sprintf("@@@@@ Enrollment register request @@@@@ Validation completed in %v", time.Since(ctx.StartTime)))

			//verify elegibility of user in tournament
			newEnrollFlag, err2 := checkUserElegibilityForPromotion(app, ctx.Tournament, ctx.Data.ListType, ctx.Data.UserID)
			if err2 != nil {
				return e.JSON(http.StatusForbidden, ErrorResponse{
					Error:   "USER_ELIGIBILITY_FAILED",
					Message: err2.Error(),
					Code:    http.StatusForbidden,
				})
			}

			// Execute update in enrollment with check on capacity if needed
			err3 := executeDBEnrollment(app, ctx.Data.UserID, ctx.Data.TournamentID, ctx.Data.ListType, newEnrollFlag)
			if err3 != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "ENROLLMENT_FAILED",
					Message: err3.Error(),
					Code:    http.StatusBadRequest,
				})
			}
			app.Logger().Info(fmt.Sprintf("@@@@@ Enrollment register request @@@@@ Execution  -- completed in %v", time.Since(ctx.StartTime)))

			return e.JSON(http.StatusOK, SuccessResponse{
				Success: true,
				Message: fmt.Sprintf("User enrolled in the tournament into %s successfully", ctx.Data.ListType),
				Data: map[string]string{
					"user_id":       ctx.Data.UserID,
					"tournament_id": ctx.Data.TournamentID,
					"list_type":     ctx.Data.ListType,
				},
			})
		}).Bind(apis.RequireAuth())

		return se.Next()
	})
}

// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
// Sub functions for checks
// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
// Common validation pipeline
func validateEnrollmentRequest(e *core.RequestEvent, app *pocketbase.PocketBase) (*ValidationContext, *ErrorResponse) {
	ctx := &ValidationContext{
		App:       app,
		StartTime: time.Now(),
	}

	// Step 1: Authentication check
	if err := ctx.validateAuthentication(e); err != nil {
		return nil, err
	}

	// Step 2: Request body parsing and validation
	if err := ctx.validateRequestBody(e); err != nil {
		return nil, err
	}

	// Step 3: Required fields validation
	if err := ctx.validateRequiredFields(); err != nil {
		return nil, err
	}

	// Step 4: List type validation
	if err := ctx.validateListType(); err != nil {
		return nil, err
	}

	// Step 5: Organizer and tournament state validation
	if err := ctx.validateOrganizerAndTournament(); err != nil {
		return nil, err
	}

	return ctx, nil
}

// Authentication validation
func (ctx *ValidationContext) validateAuthentication(e *core.RequestEvent) *ErrorResponse {
	authRecord := e.Auth
	if authRecord == nil {
		return &ErrorResponse{
			Error:   "UNAUTHORIZED",
			Message: "Authentication required",
			Code:    http.StatusUnauthorized,
		}
	}
	ctx.RequesterUserID = authRecord.Id
	return nil
}

// Request body validation
func (ctx *ValidationContext) validateRequestBody(e *core.RequestEvent) *ErrorResponse {
	if err := e.BindBody(&ctx.Data); err != nil {
		return &ErrorResponse{
			Error:   "INVALID_REQUEST",
			Message: "Invalid request body format",
			Code:    http.StatusBadRequest,
		}
	}
	return nil
}

// Required fields validation
func (ctx *ValidationContext) validateRequiredFields() *ErrorResponse {
	if ctx.Data.UserID == "" || ctx.Data.TournamentID == "" ||
		ctx.Data.ListType == "" || ctx.Data.FromOwner == nil {
		return &ErrorResponse{
			Error:   "MISSING_REQUIRED_FIELDS",
			Message: "id_user, id_tournament, from_owner and list_type are required",
			Code:    http.StatusBadRequest,
		}
	}
	return nil
}

// List type validation
func (ctx *ValidationContext) validateListType() *ErrorResponse {
	validListTypes := []string{enrollmentListRegistered, enrollmentListPreRegistered, enrollmentListWaiting}
	if !slices.Contains(validListTypes, ctx.Data.ListType) {
		return &ErrorResponse{
			Error:   "INVALID_LIST_TYPE",
			Message: "list_type must be one of: registered, preregistered, waiting",
			Code:    http.StatusBadRequest,
		}
	}
	return nil
}

// Organizer and tournament validation
func (ctx *ValidationContext) validateOrganizerAndTournament() *ErrorResponse {
	tournament, err := validateOrganizerUserAndTournamentState(
		ctx.App,
		ctx.RequesterUserID,
		ctx.Data.UserID,
		ctx.Data.TournamentID,
		*ctx.Data.FromOwner,
	)
	if err != nil {
		return &ErrorResponse{
			Error:   "ORGANIZER_VERIFICATION_FAILED",
			Message: err.Error(),
			Code:    http.StatusForbidden,
		}
	}
	ctx.Tournament = tournament
	return nil
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// Sub functions for the API
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

func validateOrganizerUserAndTournamentState(app *pocketbase.PocketBase, userIDRequestor string, userID string, tournamentID string, fromOwner bool) (*core.Record, error) {

	//check if user is the organizer of the providerd tournament
	collectionT, err := app.FindCollectionByNameOrId("tournaments")
	if err != nil {
		return nil, fmt.Errorf("failed to find tournaments collection: %w", err)
	}

	tournament, err := app.FindFirstRecordByFilter(
		collectionT,
		"id = {:id}",
		dbx.Params{
			"id": tournamentID,
		},
	)

	if err != nil {
		return nil, fmt.Errorf("tournament not found: %w", err)
	}

	// If fromOwner is true, check if the requester user is the owner of the tournament
	// Otherwise check that the requester user is the same as the user targeted for the enrollment change
	if fromOwner {
		collectionU, err := app.FindCollectionByNameOrId("users")
		if err != nil {
			return nil, fmt.Errorf("failed to find users collection: %w", err)
		}

		user, err := app.FindRecordById(collectionU, userIDRequestor)
		if err != nil {
			return nil, fmt.Errorf("caller user not found")
		}

		// Check if user is an organizer
		organizer := user.GetBool("organizer")
		if !organizer {
			return nil, fmt.Errorf("access denied: user is not an organizer")
		}

		tournamentOwnerID := tournament.GetString("id_owner")
		if tournamentOwnerID != userIDRequestor {
			return nil, fmt.Errorf("access denied: user is not the owner of the tournament")
		}
	} else {
		if userID != userIDRequestor {
			return nil, fmt.Errorf("access denied: user can only modify their own enrollments")
		}
	}

	state := tournament.GetString("state")
	if state != "open" {
		return nil, fmt.Errorf("tournament is not in a state that allows enrollments (current state: %s)", state)
	}

	return tournament, nil
}

func checkUserElegibilityForPromotion(app *pocketbase.PocketBase, tournament *core.Record, listType string, userID string) (bool, error) {
	collectionE, err := app.FindCollectionByNameOrId("enrollments")
	if err != nil {
		return false, fmt.Errorf("failed to find enrollments collection: %w", err)
	}

	enrollment, err := app.FindFirstRecordByFilter(
		collectionE,
		"id_tournament = {:tournament} && id_user = {:user}",
		dbx.Params{
			"tournament": tournament.GetString("id"),
			"user":       userID,
		},
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			return true, nil // No enrollment found, user can enroll
		}
		return false, fmt.Errorf("failed to check user enrollment: %w", err)
	}

	enrollmentKind := enrollment.GetString("listKind")
	switch enrollmentKind {
	case enrollmentListWaiting:
		if listType == enrollmentListWaiting {
			return false, fmt.Errorf("the user is already in the same list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
		}
		//No error so just check capacity
		return false, nil
	case enrollmentListRegistered:
		if listType == enrollmentListRegistered {
			return false, fmt.Errorf("the user is already in the same list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
		}
		return false, fmt.Errorf("the user is already in higher list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
	case enrollmentListPreRegistered:
		if listType == enrollmentListPreRegistered {
			return false, fmt.Errorf("the user is already in the same list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
		}
		if listType == enrollmentListWaiting {
			return false, fmt.Errorf("the user is already in higher list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
		}
		//No error so just check capacity
		return false, nil
	default:
		return false, fmt.Errorf("invalid enrollment kind %s in this tournament", enrollmentKind)
	}

}

func checkUserElegibilityForDeletion(app *pocketbase.PocketBase, tournament *core.Record, listType string, userID string) error {
	collectionE, err := app.FindCollectionByNameOrId("enrollments")
	if err != nil {
		return fmt.Errorf("failed to find enrollments collection: %w", err)
	}

	_, err2 := app.FindFirstRecordByFilter(
		collectionE,
		"id_tournament = {:tournament} && id_user = {:user} && listKind = {:listKind}",
		dbx.Params{
			"tournament": tournament.GetString("id"),
			"user":       userID,
			"listKind":   listType,
		},
	)

	if err2 != nil {
		return fmt.Errorf("failed to check user enrollment: %w", err)
	}

	return nil
}

func gatherUserDetailsForEnrollment(app *pocketbase.PocketBase, tournament *core.Record, listType string, userID string) (*UserDetailSucessResponse, error) {
	// Prepare default response
	var userDetailSucessResponse UserDetailSucessResponse = UserDetailSucessResponse{
		Found:                false,
		Enrolled:             false,
		Eligible:             false,
		Name:                 "",
		Surname:              "",
		Username:             "",
		ListType:             "",
		NotEligibilityReason: "",
	}

	// Check if user exists and get basic details
	collectionU, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		return &userDetailSucessResponse, fmt.Errorf("failed to find users collection: %w", err)
	}

	user, err := app.FindRecordById(collectionU, userID)
	if err != nil {
		return &userDetailSucessResponse, fmt.Errorf("caller user not found")
	} else {
		userDetailSucessResponse.Found = true
		userDetailSucessResponse.Name = user.GetString("name")
		userDetailSucessResponse.Surname = user.GetString("surname")
		userDetailSucessResponse.Username = user.GetString("username")
	}

	// Check if user is enrolled in the tournament and get enrollment details
	collectionE, err := app.FindCollectionByNameOrId("enrollments")
	if err != nil {
		return &userDetailSucessResponse, fmt.Errorf("failed to find enrollments collection: %w", err)
	}

	enrollment, err := app.FindFirstRecordByFilter(
		collectionE,
		"id_tournament = {:tournament} && id_user = {:user}",
		dbx.Params{
			"tournament": tournament.GetString("id"),
			"user":       userID,
		},
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			userDetailSucessResponse.Enrolled = false
			userDetailSucessResponse.Eligible = true // Not enrolled, so eligible to enroll
			userDetailSucessResponse.ListType = ""
			return &userDetailSucessResponse, nil
		}
		return &userDetailSucessResponse, fmt.Errorf("failed to check user enrollment: %w", err)
	} else {
		userDetailSucessResponse.Enrolled = true
		enrollmentKind := enrollment.GetString("listKind")
		userDetailSucessResponse.ListType = enrollmentKind

		switch enrollmentKind {
		case enrollmentListWaiting:
			if listType == enrollmentListWaiting {
				userDetailSucessResponse.Eligible = false
				userDetailSucessResponse.NotEligibilityReason = "the user is already in the same list for this tournament"
			}
			userDetailSucessResponse.Eligible = true
		case enrollmentListRegistered:
			userDetailSucessResponse.Eligible = false
			if listType == enrollmentListRegistered {
				userDetailSucessResponse.NotEligibilityReason = "the user is already in the same list for this tournament"
			} else {
				userDetailSucessResponse.NotEligibilityReason = "the user is already in higher list for this tournament"
			}
		case enrollmentListPreRegistered:
			if listType == enrollmentListPreRegistered {
				userDetailSucessResponse.Eligible = false
				userDetailSucessResponse.NotEligibilityReason = "the user is already in the same list for this tournament"
			}
			if listType == enrollmentListWaiting {
				userDetailSucessResponse.Eligible = false
				userDetailSucessResponse.NotEligibilityReason = "the user is already in higher list for this tournament"
			}
			userDetailSucessResponse.Eligible = true
		default:
			return &userDetailSucessResponse, fmt.Errorf("invalid enrollment kind %s in this tournament", enrollmentKind)
		}
	}
	return &userDetailSucessResponse, nil
}

func executeDBEnrollment(app *pocketbase.PocketBase, userID string, tournamentID string, listType string, newEnrollFlag bool) error {
	err := app.RunInTransaction(func(txApp core.App) error {
		var err2 error
		var result sql.Result
		if newEnrollFlag {
			if listType == enrollmentListRegistered || listType == enrollmentListPreRegistered {
				result, err2 = txApp.DB().NewQuery(
					`INSERT INTO enrollments (id_user, id_tournament, listKind, created, updated)
					SELECT {:id_tournament}, {:id_user}, {:listKind}, datetime('now'), datetime('now')
					WHERE (
						SELECT COUNT(*) FROM enrollments WHERE id_tournament = {:id_tournament} AND listKind IN ('registered', 'preregistered')
					) < (
						SELECT capacity FROM tournaments WHERE id = {:id_tournament}
					)`).
					Bind(dbx.Params{
						"id_tournament": tournamentID,
						"id_user":       userID,
						"listKind":      listType,
					}).
					Execute()
			} else {
				result, err2 = txApp.DB().NewQuery(
					`INSERT INTO enrollments (id_user, id_tournament, listKind, created, updated)
					SELECT {:id_tournament}, {:id_user}, {:listKind}, datetime('now'), datetime('now')`).
					Bind(dbx.Params{
						"id_tournament": tournamentID,
						"id_user":       userID,
						"listKind":      listType,
					}).
					Execute()
			}
		} else {
			if listType == enrollmentListRegistered || listType == enrollmentListPreRegistered {
				result, err2 = txApp.DB().NewQuery(
					`UPDATE enrollments 
					SET listKind = {:listKind}, updated = datetime('now')
					WHERE 
						id_user = {:id_user} 
						AND id_tournament = {:id_tournament}
						AND (
								listKind IN ('registered', 'preregistered')
							OR
								(SELECT COUNT(*) FROM enrollments e2 WHERE e2.id_tournament = {:id_tournament} AND e2.listKind IN ('registered', 'preregistered')) 
								< (SELECT capacity FROM tournaments WHERE id = {:id_tournament})
				)`).
					Bind(dbx.Params{
						"id_tournament": tournamentID,
						"id_user":       userID,
						"listKind":      listType,
					}).
					Execute()
			} else {
				result, err2 = txApp.DB().NewQuery(
					`UPDATE enrollments 
					SET listKind = {:listKind}, updated = datetime('now')
					WHERE
						id_user = {:id_user} 
						AND id_tournament = {:id_tournament}
				)`).
					Bind(dbx.Params{
						"id_tournament": tournamentID,
						"id_user":       userID,
						"listKind":      listType,
					}).
					Execute()
			}

		}
		if err2 != nil {
			return fmt.Errorf("update failed: %w", err2)
		}
		rowsAffected, _ := result.RowsAffected()
		if rowsAffected == 0 {
			return fmt.Errorf("enrollment not found for user %s in tournament %s", userID, tournamentID)
		} else {
			collectionT, err := app.FindCollectionByNameOrId("tournaments")
			if err != nil {
				return fmt.Errorf("failed to find tournaments collection: %w", err)
			}

			tournament, err := app.FindFirstRecordByFilter(
				collectionT,
				"id = {:id}",
				dbx.Params{
					"id": tournamentID,
				},
			)

			if err != nil {
				return fmt.Errorf("tournament not found: %w", err)
			}

			//Update lastUpdated_enrollments in tournament
			tournament.Set("lastUpdated_enrollments", dbx.NewExp("datetime('now')"))
			if err := txApp.Save(tournament); err != nil {
				return fmt.Errorf("failed to update tournament lastUpdated_enrollments: %w", err)
			}
		}

		return nil
	})
	return err
}

func executeDBEnrollmentDeletion(app *pocketbase.PocketBase, userID string, tournamentID string, listType string) error {
	err := app.RunInTransaction(func(txApp core.App) error {
		var err2 error
		var result sql.Result
		result, err2 = txApp.DB().NewQuery(
			`DELETE FROM enrollments	
			WHERE
				id_user = {:id_user}
				AND id_tournament = {:id_tournament}
				AND listKind = {:listKind}
		`).
			Bind(dbx.Params{
				"id_tournament": tournamentID,
				"id_user":       userID,
				"listKind":      listType,
			}).
			Execute()

		if err2 != nil {
			return fmt.Errorf("deletion failed: %w", err2)
		}

		rowsAffected, _ := result.RowsAffected()
		if rowsAffected == 0 {
			return fmt.Errorf("enrollment not found for user %s in tournament %s", userID, tournamentID)
		} else {
			collectionT, err := app.FindCollectionByNameOrId("tournaments")
			if err != nil {
				return fmt.Errorf("failed to find tournaments collection: %w", err)
			}

			tournament, err := app.FindFirstRecordByFilter(
				collectionT,
				"id = {:id}",
				dbx.Params{
					"id": tournamentID,
				},
			)

			if err != nil {
				return fmt.Errorf("tournament not found: %w", err)
			}

			//Update lastUpdated_enrollments in tournament
			tournament.Set("lastUpdated_enrollments", dbx.NewExp("datetime('now')"))
			if err := txApp.Save(tournament); err != nil {
				return fmt.Errorf("failed to update tournament lastUpdated_enrollments: %w", err)
			}
		}

		return nil
	})
	return err
}
