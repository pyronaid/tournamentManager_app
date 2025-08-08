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
					Message: "user_id, tournament_id, and list_type are required",
					Code:    http.StatusBadRequest,
				})
			}

			//Validate list_type parameter
			validListTypes := []string{"registered", "waiting", "preregistered"}
			if !slices.Contains(validListTypes, data.ListType) {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "INVALID_LIST_TYPE",
					Message: "list_type must be one of: registered, waiting, preregistered",
					Code:    http.StatusBadRequest,
				})
			}

			// Verify caller is an organizer
			tournament, err1 := validateOrganizerUser(app, requesterUserID, data.TournamentID)
			if err1 != nil {
				return e.JSON(http.StatusForbidden, ErrorResponse{
					Error:   "ORGANIZER_VERIFICATION_FAILED",
					Message: err1.Error(),
					Code:    http.StatusForbidden,
				})
			}

			//verify elegibility of user in tournament
			err2 := checkUserElegibility(app, tournament, data.ListType, data.UserID)
			if err2 != nil {
				return e.JSON(http.StatusForbidden, ErrorResponse{
					Error:   "USER_ELIGIBILITY_FAILED",
					Message: err2.Error(),
					Code:    http.StatusForbidden,
				})
			}

			return e.JSON(http.StatusOK, SuccessResponse{
				Success: true,
				Message: "User is eligible to enroll in the tournament",
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

func validateOrganizerUser(app *pocketbase.PocketBase, userID string, tournamentID string) (*core.Record, error) {
	collectionU, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		return nil, fmt.Errorf("failed to find users collection: %w", err)
	}

	user, err := app.FindRecordById(collectionU, userID)
	if err != nil {
		return nil, fmt.Errorf("caller user not found")
	}

	// Check if user is an organizer
	organizer := user.GetBool("organizer")
	if !organizer {
		return nil, fmt.Errorf("access denied: user is not an organizer")
	}

	//check if user is the organizer of the providerd tournament
	collectionT, err := app.FindCollectionByNameOrId("tournaments")
	if err != nil {
		return nil, fmt.Errorf("failed to find users collection: %w", err)
	}

	tournament, err := app.FindFirstRecordByFilter(
		collectionT,
		"id = {:id} && id_owner = {:owner}",
		dbx.Params{
			"id":    tournamentID,
			"owner": userID,
		},
	)
	if err != nil {
		return nil, fmt.Errorf("caller user is not the organizer of the tournament")
	}

	return tournament, nil
}

func checkUserElegibility(app *pocketbase.PocketBase, tournament *core.Record, listType string, userID string) error {
	collectionE, err := app.FindCollectionByNameOrId("enrollments")
	if err != nil {
		return fmt.Errorf("failed to find enrollments collection: %w", err)
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
			return nil // No enrollment found, user can enroll
		}
		return fmt.Errorf("failed to check user enrollment: %w", err)
	}
	enrollmentKind := enrollment.GetString("listKind")
	switch enrollmentKind {
	case "waiting":
		if listType == "waiting" {
			return fmt.Errorf("the user is already in the same list for this tournament: %w", err)
		}
		//No error so just check capacity
		return nil
	case "registered":
		if listType == "registered" {
			return fmt.Errorf("the user is already in the same list for this tournament: %w", err)
		}
		return fmt.Errorf("the user is already in higher list for this tournament: %w", err)
	case "preregistered":
		if listType == "preregistered" {
			return fmt.Errorf("the user is already in the same list for this tournament: %w", err)
		}
		if listType == "waiting" {
			return fmt.Errorf("the user is already in higher list for this tournament: %w", err)
		}
		//No error so just check capacity
		return nil
	default:
		return fmt.Errorf("invalid enrollment kind %s in this tournament: %w", enrollmentKind, err)
	}

}
