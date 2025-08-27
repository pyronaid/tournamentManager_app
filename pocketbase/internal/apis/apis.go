package apis

import (
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"slices"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

type NewEnrollmentRequest struct {
	UserID       string `json:"id_user" validate:"required"`
	TournamentID string `json:"id_tournament" validate:"required"`
	ListType     string `json:"list_type" validate:"required"`
	FromOwner    *bool  `json:"from_owner" validate:"required"`
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
	Code    int    `json:"code"`
}

type SuccessResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

const (
	enrollmentListRegistered    = "registered"
	enrollmentListWaiting       = "waiting"
	enrollmentListPreRegistered = "preregistered"
)

func RegisterTournamentEnrollmentAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.POST("/api/tournamentManager/enroll", func(e *core.RequestEvent) error {

			//check1 User logged
			authRecord := e.Auth
			if authRecord == nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "UNAUTHORIZED",
					Message: "Authentication required",
					Code:    http.StatusUnauthorized,
				})
			}
			requesterUserID := authRecord.Id

			//check data sent required
			var data NewEnrollmentRequest
			if err := e.BindBody(&data); err != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "INVALID_REQUEST",
					Message: "Invalid request body format",
					Code:    http.StatusBadRequest,
				})
			}

			// Basic validation
			if data.UserID == "" || data.TournamentID == "" || data.ListType == "" {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "MISSING_REQUIRED_FIELDS",
					Message: "user_id, tournament_id, from_owner and list_type are required",
					Code:    http.StatusBadRequest,
				})
			}

			//Validate list_type parameter
			validListTypes := []string{enrollmentListRegistered, enrollmentListPreRegistered, enrollmentListWaiting}
			if !slices.Contains(validListTypes, data.ListType) {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "INVALID_LIST_TYPE",
					Message: "list_type must be one of: registered, preregistered, waiting",
					Code:    http.StatusBadRequest,
				})
			}

			// Verify caller is an organizer and tournament is in correct state
			tournament, err1 := validateOrganizerUserAndTournamentState(app, requesterUserID, data.TournamentID, *data.FromOwner)
			if err1 != nil {
				return e.JSON(http.StatusForbidden, ErrorResponse{
					Error:   "ORGANIZER_VERIFICATION_FAILED",
					Message: err1.Error(),
					Code:    http.StatusForbidden,
				})
			}

			//verify elegibility of user in tournament
			newEnrollFlag, err2 := checkUserElegibility(app, tournament, data.ListType, data.UserID)
			if err2 != nil {
				return e.JSON(http.StatusForbidden, ErrorResponse{
					Error:   "USER_ELIGIBILITY_FAILED",
					Message: err2.Error(),
					Code:    http.StatusForbidden,
				})
			}

			// Execute update in enrollment with check on capacity if needed
			err3 := executeDBEnrollment(app, data.UserID, data.TournamentID, data.ListType, newEnrollFlag)
			if err3 != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "ENROLLMENT_FAILED",
					Message: err3.Error(),
					Code:    http.StatusBadRequest,
				})
			}

			return e.JSON(http.StatusOK, SuccessResponse{
				Success: true,
				Message: fmt.Sprintf("User enrolled in the tournament into %s successfully", data.ListType),
				Data: map[string]string{
					"user_id":       data.UserID,
					"tournament_id": data.TournamentID,
					"list_type":     data.ListType,
				},
			})
		}).Bind(apis.RequireAuth())

		return se.Next()
	})
}

func RegisterHeathCheckAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.GET("/api/myhealthcheck", func(e *core.RequestEvent) error {
			return e.JSON(http.StatusOK, SuccessResponse{
				Success: true,
				Message: "API is healthy",
				Data: map[string]string{
					"status": "OK",
				},
			})
		})

		return se.Next()
	})
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// Sub functions for the API
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

func validateOrganizerUserAndTournamentState(app *pocketbase.PocketBase, userID string, tournamentID string, fromOwner bool) (*core.Record, error) {
	collectionU, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		return nil, fmt.Errorf("failed to find users collection: %w", err)
	}

	user, err := app.FindRecordById(collectionU, userID)
	if err != nil {
		return nil, fmt.Errorf("caller user not found")
	}

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

	// If fromOwner is true, check if the user is the owner of the tournament
	if fromOwner {
		// Check if user is an organizer
		organizer := user.GetBool("organizer")
		if !organizer {
			return nil, fmt.Errorf("access denied: user is not an organizer")
		}

		tournamentOwnerID := tournament.GetString("id_owner")
		if tournamentOwnerID != userID {
			return nil, fmt.Errorf("access denied: user is not the owner of the tournament")
		}
	}

	state := tournament.GetString("state")
	if state != "open" {
		return nil, fmt.Errorf("tournament is not in a state that allows enrollments (current state: %s)", state)
	}

	return tournament, nil
}

func checkUserElegibility(app *pocketbase.PocketBase, tournament *core.Record, listType string, userID string) (bool, error) {
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
	case "waiting":
		if listType == "waiting" {
			return false, fmt.Errorf("the user is already in the same list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
		}
		//No error so just check capacity
		return false, nil
	case "registered":
		if listType == "registered" {
			return false, fmt.Errorf("the user is already in the same list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
		}
		return false, fmt.Errorf("the user is already in higher list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
	case "preregistered":
		if listType == "preregistered" {
			return false, fmt.Errorf("the user is already in the same list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
		}
		if listType == "waiting" {
			return false, fmt.Errorf("the user is already in higher list for this tournament (from: %s to:%s user:%s)", enrollmentKind, listType, userID)
		}
		//No error so just check capacity
		return false, nil
	default:
		return false, fmt.Errorf("invalid enrollment kind %s in this tournament", enrollmentKind)
	}

}

func executeDBEnrollment(app *pocketbase.PocketBase, userID string, tournamentID string, listType string, newEnrollFlag bool) error {
	err := app.RunInTransaction(func(txApp core.App) error {
		var err2 error
		var result sql.Result
		if newEnrollFlag {
			if listType == enrollmentListRegistered || listType == enrollmentListPreRegistered {
				result, err2 = txApp.DB().NewQuery(
					`INSERT INTO enrollments (id_user, id_tournament, listKind, created)
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
						"updated":       dbx.NewExp("datetime('now')"),
					}).
					Execute()
			} else {
				result, err2 = txApp.DB().NewQuery(
					`INSERT INTO enrollments (id_user, id_tournament, listKind, created)
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
			if err := app.Save(tournament); err != nil {
				return fmt.Errorf("failed to update tournament lastUpdated_enrollments: %w", err)
			}
		}
		return nil
	})
	return err
}
