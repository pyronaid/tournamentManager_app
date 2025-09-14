//ROUND
//   roundId
//   tournament_id
//   roundIndex
//   roundKind (swiss, topcut)
//   roundSize (only for topcut)
//   completed (bool)
//   created
//   updated
//// tournament_id + roundIndex unique index
//RANKING
//   rankingId
//	 tournament_id
//   round_id
//   roundIndex -- ext
//   roundKind -- ext
//   roundSize -- ext
//   user_id
//   name -- ext
//   surname -- ext
//   username -- ext
//   points
//   TB1
//   TB2
//   TB3
//   dropped (bool)
//   created
//   updated
//// tournament_id + round_id + user_id unique index
//PAIRING
//   pairingId
//   tournament_id
//   round_id
//   roundIndex -- ext
//   roundKind -- ext
//   roundSize -- ext
//   playerA (user_id or bye_id)
//   dropPlayerA (bool)
//   playerB (user_id or bye_id)
//   dropPlayerB (bool)
//   isBye (bool)
//   tableIndex
//   winner (user_id or empty if not finished)
//   created
//   updated
//// tournament_id + round_id + playerA unique index
//// tournament_id + round_id + playerB unique index

package apis

import (
	"crypto/rand"
	"database/sql"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"slices"
	"time"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

type RoundsRequest struct {
	TournamentID string `json:"id_tournament" validate:"required"`
	RoundKind    string `json:"round_kind" validate:"required"`
	RoundSize    *int   `json:"round_size" validate:"optional"`
}

type RoundsDelRequest struct {
	TournamentID string `json:"id_tournament" validate:"required"`
	RoundKind    string `json:"round_kind" validate:"required"`
	RoundSize    *int   `json:"round_size" validate:"optional"`
	RoundIndex   int    `json:"round_index" validate:"required"`
	RoundId      string `json:"round_id" validate:"required"`
}

// Validation context to track request state
type ValidationContextRound struct {
	App             *pocketbase.PocketBase
	RequesterUserID string
	Data            RoundsRequest
	DataDel         RoundsDelRequest
	Tournament      *core.Record
	RoundIndex      int
	RoundSize       int
	StartTime       time.Time
}

type PairingUserData struct {
	UserId       string
	TournamentId string
	Points       int
	TB1          float64
	TB2          float64
	TB3          float64
}

type PairingMatchData struct {
	UserIdPlayerA string
	UserIdPlayerB string
	TournamentId  string
	RoundId       string
	RoundIndex    int
	IsBye         bool
	TableIndex    int
	UserIdWinner  string
}

const (
	roundKindTopCut = "topcut"
	roundKindSwiss  = "swiss"
	ByePlayerID     = "00000000000000000000000000"
)

func CreateRoundAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.POST("/api/tournamentManager/generateRound", func(e *core.RequestEvent) error {
			// Common validation pipeline
			ctx, validationErr := validateRoundsGenerationRequest(e, app)
			if validationErr != nil {
				return sendErrorResponse(e, validationErr)
			}

			// Execute update in enrollment with check on capacity if needed
			err := executeDBRound(app, ctx.Data.TournamentID, ctx.Data.RoundKind, ctx.RoundIndex, ctx.RoundSize)
			if err != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "ROUND_GENERATION_FAILED",
					Message: err.Error(),
					Code:    http.StatusBadRequest,
				})
			}

			return e.JSON(http.StatusOK, SuccessResponse{
				Success: true,
				Message: "Round created successfully",
				Data: map[string]string{
					"roundKind":     ctx.Data.RoundKind,
					"tournament_id": ctx.Data.TournamentID,
					"roundSize":     fmt.Sprintf("%v", ctx.Data.RoundSize),
				},
			})

		}).Bind(apis.RequireAuth())

		return se.Next()
	})
}

func DeleteRoundAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.POST("/api/tournamentManager/deleteRound", func(e *core.RequestEvent) error {
			// Common validation pipeline
			ctx, validationErr := validateRoundsDeletionRequest(e, app)
			if validationErr != nil {
				return sendErrorResponse(e, validationErr)
			}

			// Execute update in enrollment with check on capacity if needed
			err := executeDBDeleteRound(app, ctx.DataDel.TournamentID, ctx.DataDel.RoundId, ctx.DataDel.RoundIndex)
			if err != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "ROUND_DELETION_FAILED",
					Message: err.Error(),
					Code:    http.StatusBadRequest,
				})
			}

			return e.JSON(http.StatusOK, SuccessResponse{
				Success: true,
				Message: "Round deleted successfully",
				Data: map[string]string{
					"roundKind":     ctx.Data.RoundKind,
					"tournament_id": ctx.Data.TournamentID,
					"roundSize":     fmt.Sprintf("%v", ctx.Data.RoundSize),
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
func validateRoundsGenerationRequest(e *core.RequestEvent, app *pocketbase.PocketBase) (*ValidationContextRound, *ErrorResponse) {
	ctx, err := validateRoundsRequest(e, app, false)
	if err != nil {
		return nil, err
	}

	// Step 6: round concistency
	app.Logger().Info("validateRoundConsistency")
	if err := ctx.validateRoundConsistency(app); err != nil {
		return nil, err
	}
	return ctx, nil
}
func validateRoundsDeletionRequest(e *core.RequestEvent, app *pocketbase.PocketBase) (*ValidationContextRound, *ErrorResponse) {
	ctx, err := validateRoundsRequest(e, app, true)
	if err != nil {
		return nil, err
	}

	return ctx, nil
}
func validateRoundsRequest(e *core.RequestEvent, app *pocketbase.PocketBase, delFlag bool) (*ValidationContextRound, *ErrorResponse) {
	ctx := &ValidationContextRound{
		App:       app,
		StartTime: time.Now(),
	}

	// Step 1: Authentication check
	app.Logger().Info("validateAuthentication")
	if err := ctx.validateAuthentication(e); err != nil {
		return nil, err
	}

	// Step 2: Request body parsing and validation
	app.Logger().Info("validateRequestBody")
	if err := ctx.validateRequestBody(e, delFlag); err != nil {
		return nil, err
	}

	// Step 3: Required fields validation
	app.Logger().Info("validateRequiredFields")
	if err := ctx.validateRequiredFields(delFlag); err != nil {
		return nil, err
	}

	// Step 4: List type validation
	app.Logger().Info("validateListType")
	if err := ctx.validateListType(); err != nil {
		return nil, err
	}

	// Step 5: Organizer and tournament state validation
	app.Logger().Info("validateOrganizerAndTournament")
	if err := ctx.validateOrganizerAndTournament(); err != nil {
		return nil, err
	}

	// Step 6: round feasibility
	app.Logger().Info("validateRoundFeasibility")
	if err := ctx.validateRoundFeasibility(delFlag); err != nil {
		return nil, err
	}

	return ctx, nil
}

// Authentication validation
func (ctx *ValidationContextRound) validateAuthentication(e *core.RequestEvent) *ErrorResponse {
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
func (ctx *ValidationContextRound) validateRequestBody(e *core.RequestEvent, delFlag bool) *ErrorResponse {
	if delFlag {
		if err := e.BindBody(&ctx.DataDel); err != nil {
			return &ErrorResponse{
				Error:   "INVALID_REQUEST",
				Message: "Invalid request body format",
				Code:    http.StatusBadRequest,
			}
		}
	} else {
		if err := e.BindBody(&ctx.Data); err != nil {
			return &ErrorResponse{
				Error:   "INVALID_REQUEST",
				Message: "Invalid request body format",
				Code:    http.StatusBadRequest,
			}
		}
	}
	return nil
}

// Required fields validation
func (ctx *ValidationContextRound) validateRequiredFields(delFlag bool) *ErrorResponse {
	if delFlag {
		if ctx.DataDel.TournamentID == "" || ctx.DataDel.RoundIndex == 0 || ctx.DataDel.RoundId == "" || ctx.Data.RoundKind == "" {
			return &ErrorResponse{
				Error:   "MISSING_REQUIRED_FIELDS",
				Message: "tournament_id, round_kind are required",
				Code:    http.StatusBadRequest,
			}
		}
	} else {
		if ctx.Data.TournamentID == "" || ctx.Data.RoundKind == "" ||
			(ctx.Data.RoundKind == roundKindTopCut && ctx.Data.RoundSize == nil) {
			return &ErrorResponse{
				Error:   "MISSING_REQUIRED_FIELDS",
				Message: "tournament_id, round_kind are required",
				Code:    http.StatusBadRequest,
			}
		}
	}
	return nil
}

// Round Kind validation
func (ctx *ValidationContextRound) validateListType() *ErrorResponse {
	validRoundKind := []string{roundKindTopCut, roundKindSwiss}
	if !slices.Contains(validRoundKind, ctx.Data.RoundKind) {
		return &ErrorResponse{
			Error:   "INVALID_LIST_TYPE",
			Message: "round_kind must be one of: topcut, swiss",
			Code:    http.StatusBadRequest,
		}
	}
	return nil
}

// Organizer and tournament validation
func (ctx *ValidationContextRound) validateOrganizerAndTournament() *ErrorResponse {
	tournament, err := validateOrganizerUserAndTournamentStateForRound(
		ctx.App,
		ctx.RequesterUserID,
		ctx.Data.TournamentID,
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

func (ctx *ValidationContextRound) validateRoundConsistency(app *pocketbase.PocketBase) *ErrorResponse {
	collectionR, err := app.FindCollectionByNameOrId("rounds")
	if err != nil {
		return &ErrorResponse{
			Error:   "ROUNDS_COLLECTION_NOT_FOUND",
			Message: fmt.Sprintf("failed to find tournaments rounds: %v", err),
			Code:    http.StatusInternalServerError,
		}
	}

	_, err = app.FindFirstRecordByFilter(
		collectionR,
		"id_tournament = {:tournamentID} && roundIndex = {:roundIndex}", //ORDER BY ROUNDINDEX DESC
		dbx.Params{
			"tournamentID": ctx.Data.TournamentID,
			"roundIndex":   ctx.RoundIndex,
		},
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			//ok
		} else {
			return &ErrorResponse{
				Error:   "ROUNDS_CHECK_FAILED",
				Message: fmt.Sprintf("failed to check rounds for this tournament: %v", err),
				Code:    http.StatusInternalServerError,
			}
		}
	} else {
		return &ErrorResponse{
			Error:   "ROUND_ALREADY_POPULATED",
			Message: "The table round is already populated for this index",
			Code:    http.StatusBadRequest,
		}
	}

	collectionRR, err := app.FindCollectionByNameOrId("rankings")
	if err != nil {
		return &ErrorResponse{
			Error:   "RANKINGS_COLLECTION_NOT_FOUND",
			Message: fmt.Sprintf("failed to find tournaments rankings: %v", err),
			Code:    http.StatusInternalServerError,
		}
	}

	_, err = app.FindFirstRecordByFilter(
		collectionRR,
		"id_tournament = {:tournamentID} && roundIndex = {:roundIndex}", //ORDER BY ROUNDINDEX DESC
		dbx.Params{
			"tournamentID": ctx.Data.TournamentID,
			"roundIndex":   ctx.RoundIndex,
		},
	)

	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			return &ErrorResponse{
				Error:   "RANKING_ALREADY_POPULATED",
				Message: "The table ranking is already populated for this index",
				Code:    http.StatusBadRequest,
			}
		}
		return &ErrorResponse{
			Error:   "RANKINGS_CHECK_FAILED",
			Message: fmt.Sprintf("failed to check rounds for this tournament: %v", err),
			Code:    http.StatusInternalServerError,
		}
	}

	collectionP, err := app.FindCollectionByNameOrId("pairings")
	if err != nil {
		return &ErrorResponse{
			Error:   "PAIRINGS_COLLECTION_NOT_FOUND",
			Message: fmt.Sprintf("failed to find tournaments pairings: %v", err),
			Code:    http.StatusInternalServerError,
		}
	}

	_, err = app.FindFirstRecordByFilter(
		collectionP,
		"id_tournament = {:tournamentID} && roundIndex = {:roundIndex}", //ORDER BY ROUNDINDEX DESC
		dbx.Params{
			"tournamentID": ctx.Data.TournamentID,
			"roundIndex":   ctx.RoundIndex,
		},
	)

	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			return &ErrorResponse{
				Error:   "PAIRINGS_ALREADY_POPULATED",
				Message: "The table pairings is already populated for this index",
				Code:    http.StatusBadRequest,
			}
		}
		return &ErrorResponse{
			Error:   "PAIRINGS_CHECK_FAILED",
			Message: fmt.Sprintf("failed to check rounds for this tournament: %v", err),
			Code:    http.StatusInternalServerError,
		}
	}

	return nil
}

// Round Feasibility validation
// calculate the round index based
// if round is not the first check the previous is ended
// if swiss, check that the last round for tournament is not topcut
// check that the index of the round is feasible with the number of registered players
func (ctx *ValidationContextRound) validateRoundFeasibility(delFlag bool) *ErrorResponse {
	var err error
	var index int
	var size int
	if delFlag {
		err = validateRoundDelFeasibilityAndComputeIndex(
			ctx.App,
			ctx.DataDel.TournamentID,
			ctx.DataDel.RoundId,
			ctx.DataDel.RoundIndex,
		)
	} else {
		index, size, err = validateRoundFeasibilityAndComputeIndex(
			ctx.App,
			ctx.Data.TournamentID,
			ctx.Data.RoundKind,
			ctx.RoundSize,
		)
		ctx.RoundIndex = index
		ctx.RoundSize = size
	}
	if err != nil {
		return &ErrorResponse{
			Error:   "ROUND_FEASIBILITY_FAILED",
			Message: err.Error(),
			Code:    http.StatusForbidden,
		}
	}

	return nil
}

// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
// Sub functions for pairing agorithm
// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
func cryptoShuffle(a []PairingUserData) error {
	// Fisher–Yates with crypto/rand for reproducibility you can inject a RNG
	for i := len(a) - 1; i > 0; i-- {
		nBig, err := rand.Int(rand.Reader, big.NewInt(int64(i+1)))
		if err != nil {
			return err
		}
		j := int(nBig.Int64())
		a[i], a[j] = a[j], a[i]
	}
	return nil
}

func findOpponent(observedPlayer PairingUserData, playerIndex int, playerBase []PairingUserData, previousOpppo map[string]map[string]bool, stdDirection bool) (bool, PairingUserData, int) {
	var foundOppo bool
	var candidateOppo PairingUserData
	var candidateOppoIndex int
	if stdDirection {
		for candidateOppoIndex := (playerIndex + 1); candidateOppoIndex < len(playerBase); candidateOppoIndex++ {
			candidateOppo := playerBase[candidateOppoIndex]
			if innerMap, ok := previousOpppo[observedPlayer.UserId]; ok {
				if val, ok := innerMap[candidateOppo.UserId]; ok {
					// Both a and b exist, val contains the value
					if val {
						//candidateOppo is a past oppo of observedPlayer
						//continue cycling
						continue
					}
				}
			}

			foundOppo = true
			//playerBase = append(playerBase[:(playerIndex+1)], candidateOppo, playerBase[(playerIndex+1):(playerIndex+1+j)], playerBase[(playerIndex+j+2):]...)
			break
		}
	} else {
		for candidateOppoIndex := (playerIndex + 1); candidateOppoIndex > 0; candidateOppoIndex-- {
			candidateOppo := playerBase[candidateOppoIndex]
			if innerMap, ok := previousOpppo[observedPlayer.UserId]; ok {
				if val, ok := innerMap[candidateOppo.UserId]; ok {
					// Both a and b exist, val contains the value
					if val {
						//candidateOppo is a past oppo of observedPlayer
						//continue cycling
						continue
					}
				}
			}

			foundOppo = true
			//playerBase = append(playerBase[:(i+1)], candidateOppo, playerBase[(i+1):(i+1+j)], playerBase[(i+j+2):]...)
			break
		}
	}

	return foundOppo, candidateOppo, candidateOppoIndex
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
// Sub functions for the API
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

func validateOrganizerUserAndTournamentStateForRound(app *pocketbase.PocketBase, userIDRequestor string, tournamentID string) (*core.Record, error) {

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

	state := tournament.GetString("state")
	if state != "ready" {
		return nil, fmt.Errorf("tournament is not in a state that allows round gen (current state: %s)", state)
	}

	return tournament, nil
}

func validateRoundDelFeasibilityAndComputeIndex(app *pocketbase.PocketBase, tournamentID string, roundId string, roundIndex int) error {
	/////////////////////////////////////////////////////////
	//CHECK IF ROUND EXISTS
	/////////////////////////////////////////////////////////
	collectionR, err := app.FindCollectionByNameOrId("rounds")
	if err != nil {
		return fmt.Errorf("failed to find tournaments enrollments: %w", err)
	}
	round, err := app.FindRecordById(collectionR, roundId)
	if err != nil {
		return fmt.Errorf("failed to find the round to delete: %w", err)
	}
	if round.GetString("id_tournament") != tournamentID {
		return fmt.Errorf("the round to delete does not belong to the provided tournament")
	}
	if round.GetInt("roundIndex") != roundIndex {
		return fmt.Errorf("the round to delete does not have the provided index")
	}
	return nil
}
func validateRoundFeasibilityAndComputeIndex(app *pocketbase.PocketBase, tournamentID string, roundKind string, roundSize int) (int, int, error) {
	var index int
	var size int
	var roundKindLastRound string

	/////////////////////////////////////////////////////////
	//RETRIEVE THE NUM OF REGISTERED PLAYER TO ASSESS IF NEW ROUND COULD BE CREATED
	/////////////////////////////////////////////////////////
	collectionE, err := app.FindCollectionByNameOrId("enrollments")
	if err != nil {
		return index, 0, fmt.Errorf("failed to find tournaments enrollments: %w", err)
	}
	playersNum, err := app.CountRecords(
		collectionE,
		dbx.HashExp{"id_tournament": tournamentID},
		dbx.HashExp{"listKind": "registered"},
	)

	if err != nil {
		return index, size, fmt.Errorf("failed to assesst feasibility for tournament: %w", err)
	}

	/////////////////////////////////////////////////////////
	//RETRIEVE LAST ROUND FOR THIS TOURNAMENT TO COMPUTE NEW INDEX
	/////////////////////////////////////////////////////////
	collectionR, err := app.FindCollectionByNameOrId("rounds")
	if err != nil {
		return index, size, fmt.Errorf("failed to find tournaments rounds: %w", err)
	}

	round, err := app.FindFirstRecordByFilter(
		collectionR,
		"id_tournament = {:tournamentID}", //ORDER BY ROUNDINDEX DESC
		dbx.Params{
			"tournamentID": tournamentID,
		},
	)

	var roundSizeLastRound int
	var playersNextRoundNum int

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			index = 0
			size = int(playersNum)
		}
		return index, size, fmt.Errorf("failed to check rounds for this tournament: %w", err)
	} else {
		index = round.GetInt("roundIndex")
		roundKindLastRound = round.GetString("roundKind")
		roundCompletedLastRound := round.GetBool("completed")
		roundSizeLastRound = round.GetInt("roundSize")

		/////////////////////////////////////////////////////////
		//CHECK ROUND IS COMPLETED TO PROCEED
		/////////////////////////////////////////////////////////
		if !roundCompletedLastRound {
			return index, size, fmt.Errorf("the previous round is not completed yet")
		}
		/////////////////////////////////////////////////////////
		//CHECK NEW SWISS ROUND IS NOT AFTER A TOP CUT ROUND
		/////////////////////////////////////////////////////////
		if roundKind == roundKindSwiss && roundKindLastRound == roundKindTopCut {
			return index, size, fmt.Errorf("you cannot create a swiss round if you already started a topCut Round earlier")
		}

		collectionRR, err := app.FindCollectionByNameOrId("rankings")
		if err != nil {
			return index, size, fmt.Errorf("failed to find tournaments rankings: %w", err)
		}
		playersNextRoundNum, err := app.CountRecords(
			collectionRR,
			dbx.HashExp{"id_tournament": tournamentID},
			dbx.HashExp{"roundIndex": index},
			dbx.HashExp{"dropped": false},
		)

		if err != nil {
			return index, size, fmt.Errorf("failed to assesst feasibility for rankings: %w", err)
		}
		size = int(playersNextRoundNum)
	}
	/////////////////////////////////////////////////////////
	//playersNum >= 2^index TO ALLOW A NEW SWISS ROUND AND playersNum >= 2 TO ALLOW A NEW TOP CUT ROUND WITH INDEX 0
	//playersNumLastRoundNotDropped >=2
	/////////////////////////////////////////////////////////
	if roundKind == roundKindSwiss {
		if int(playersNum) >= (1 << index) {
			index++
			return index, size, nil
		} else {
			return index, size, fmt.Errorf("cannot create this swiss round with the player base of this tournament: %w", err)
		}
	} else {
		if index == 0 {
			if int(playersNum) >= roundSize {
				index++
				return index, roundSize, nil
			} else {
				return index, roundSize, fmt.Errorf("cannot create this top cut round with the player base of this tournament: %w", err)
			}
		} else {
			if roundKindLastRound == roundKindSwiss && playersNextRoundNum >= roundSize {
				//quello prima era svizzera
				index++
				return index, roundSize, nil
			} else if roundKindLastRound == roundKindSwiss && roundSizeLastRound == 2*roundSize {
				//quello prima era top cut
				index++
				return index, roundSize, nil
			} else {
				return index, roundSize, fmt.Errorf("failed to assesst feasibility for tournament")
			}
		}
	}
}

func getPlayerList(app core.App, tournamentID string, roundIndex int, roundSize int) ([]PairingUserData, map[string]map[string]bool, map[string]bool, error) {

	var usersToPair []PairingUserData
	var prevOpponents = map[string]map[string]bool{}
	var hadBye = map[string]bool{}

	add := func(a, b string) {
		if prevOpponents[a] == nil {
			prevOpponents[a] = map[string]bool{}
		}
		prevOpponents[a][b] = true
	}

	if roundIndex == 1 {
		collectionE, err := app.FindCollectionByNameOrId("enrollments")
		if err != nil {
			return usersToPair, prevOpponents, hadBye, fmt.Errorf("failed to find enrollments table: %w", err)
		}

		enrollments, err := app.FindRecordsByFilter(
			collectionE,
			"id_tournament = {:tournamentID} && listKind = 'registered'",
			"",
			-1,
			0,
			dbx.Params{
				"tournamentID": tournamentID,
			},
		)

		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				return usersToPair, prevOpponents, hadBye, fmt.Errorf("the table enrollments is not populated: %w", err)
			}
			return usersToPair, prevOpponents, hadBye, fmt.Errorf("failed to check enrollments for this tournament: %w", err)
		}

		for _, record := range enrollments {
			pairing := PairingUserData{
				UserId:       record.GetString("id_user"),
				TournamentId: record.GetString("id_tournament"),
				Points:       record.GetInt("points"),
				TB1:          record.GetFloat("TB1"),
				TB2:          record.GetFloat("TB2"),
				TB3:          record.GetFloat("TB3"),
			}
			usersToPair = append(usersToPair, pairing)
		}
	} else {
		collectionRR, err := app.FindCollectionByNameOrId("rankings")
		if err != nil {
			return usersToPair, prevOpponents, hadBye, fmt.Errorf("failed to find rankings table: %w", err)
		}

		rankings, err := app.FindRecordsByFilter(
			collectionRR,
			"id_tournament = {:tournamentID} && roundIndex = {:roundIndex} && dropped = false",
			"points,TB1,TB2,TB3",
			roundSize,
			0,
			dbx.Params{
				"tournamentID": tournamentID,
				"roundIndex":   roundIndex,
			},
		)

		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				return usersToPair, prevOpponents, hadBye, fmt.Errorf("the table rankings is not populated for the selected round: %w", err)
			}
			return usersToPair, prevOpponents, hadBye, fmt.Errorf("failed to check rankings for this tournament: %w", err)
		}

		for _, record := range rankings {
			pairing := PairingUserData{
				UserId:       record.GetString("id_user"),
				TournamentId: record.GetString("id_tournament"),
				Points:       record.GetInt("points"),
				TB1:          record.GetFloat("TB1"),
				TB2:          record.GetFloat("TB2"),
				TB3:          record.GetFloat("TB3"),
			}
			usersToPair = append(usersToPair, pairing)
		}

		//Populating history and bye map
		collectionP, err := app.FindCollectionByNameOrId("pairings")
		if err != nil {
			return usersToPair, prevOpponents, hadBye, fmt.Errorf("failed to find pairings table: %w", err)
		}

		pairings, err := app.FindRecordsByFilter(
			collectionP,
			"id_tournament = {:tournamentID} && roundIndex < {:roundIndex}",
			"",
			-1,
			0,
			dbx.Params{
				"tournamentID": tournamentID,
				"roundIndex":   roundIndex,
			},
		)

		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				return usersToPair, prevOpponents, hadBye, fmt.Errorf("the table pairings is not populated for the selected tournament: %w", err)
			}
			return usersToPair, prevOpponents, hadBye, fmt.Errorf("failed to check pairings for this tournament: %w", err)
		}

		for _, record := range pairings {
			//add info history and bye
			isBye := record.GetBool("isBye")
			idPlayerA := record.GetString("playerA")
			idPlayerB := record.GetString("playerB")
			if isBye {
				if idPlayerA != ByePlayerID {
					hadBye[idPlayerA] = true
				}
				if idPlayerB != ByePlayerID {
					hadBye[idPlayerB] = true
				}
			} else {
				add(idPlayerA, idPlayerB)
				add(idPlayerB, idPlayerA)
			}
		}

	}

	return usersToPair, prevOpponents, hadBye, nil
}

func generateRankings(app core.App, playerBase []PairingUserData, tournamentID string, roundId string) error {
	_, err := app.FindCollectionByNameOrId("rankings")
	if err != nil {
		return fmt.Errorf("failed to find rankings table: %w", err)
	}
	//RANKING
	//   rankingId
	//	 tournament_id
	//   round_id
	//   roundIndex -- ext
	//   roundKind -- ext
	//   roundSize -- ext
	//   user_id
	//   name -- ext
	//   surname -- ext
	//   username -- ext
	//   points
	//   TB1
	//   TB2
	//   TB3
	for _, player := range playerBase {
		_, err2 := app.DB().Insert("rankings", dbx.Params{
			"id_tournament": tournamentID,
			"id_round":      roundId,
			"id_user":       player.UserId,
			"points":        player.Points,
			"TB1":           player.TB1,
			"TB2":           player.TB2,
			"TB3":           player.TB3,
			"created":       time.Now(),
			"updated":       time.Now(),
		}).Execute()
		if err2 != nil {
			return fmt.Errorf("ranking insert failed: %w", err2)
		}
	}

	return nil
}

func generatePairings(app core.App, playerBase []PairingUserData, previousOpppo map[string]map[string]bool, hadBye map[string]bool, tournamentID string, roundKind string, roundIndex int, roundId string) error {
	odd := len(playerBase)%2 == 1
	var pairs []PairingMatchData
	if roundIndex == 1 {
		// Shuffle players
		if err := cryptoShuffle(playerBase); err != nil {
			return err
		}
	}

	limit := len(playerBase)
	if roundKind == roundKindSwiss {

		for i := 0; i < limit; i += 2 {
			observedPlayer := playerBase[i]
			foundOppo, candidateOppo, candidateOppoIndex := findOpponent(observedPlayer, i, playerBase, previousOpppo, true)

			if foundOppo {
				playerBase = append(
					append(
						append(
							playerBase[:(i+1)],
							candidateOppo,
						),
						playerBase[(i+1):(i+1+candidateOppoIndex)]...,
					),
					playerBase[(i+candidateOppoIndex+2):]...,
				)
			} else {
				foundOppo, candidateOppo, candidateOppoIndex := findOpponent(observedPlayer, i, playerBase, previousOpppo, false)
				if foundOppo {
					playerBase = append(
						append(
							append(
								playerBase[:candidateOppoIndex],
								playerBase[(candidateOppoIndex+1):(i+1)]...,
							),
							candidateOppo,
						),
						playerBase[(i+1):]...,
					)
					var rebalancePlayerIndex int
					oddUpSideOppo := candidateOppoIndex%2 == 1
					if oddUpSideOppo {
						rebalancePlayerIndex = candidateOppoIndex - 1
					} else {
						rebalancePlayerIndex = candidateOppoIndex + 1
					}
					foundOppo, candidateOppo, candidateOppoIndex := findOpponent(playerBase[rebalancePlayerIndex], i, playerBase, previousOpppo, true)
					if !foundOppo {
						return errors.New("i cannot avoid rematch in this tournament and in this round")
					} else {
						playerBase = append(
							append(
								playerBase[:rebalancePlayerIndex+1],
								candidateOppo,
							),
							append(
								playerBase[(rebalancePlayerIndex+2):candidateOppoIndex],
								playerBase[candidateOppoIndex+1:]...,
							)...,
						)
					}
				} else {
					return errors.New("i cannot avoid rematch in this tournament and in this round")
				}
			}
		}

		var last = playerBase[len(playerBase)-1]
		if odd {
			var counterForAvoidByeDuplication = 0
			//add bye at the bottom
			for i := 0; i < len(playerBase); i++ {

				last = playerBase[len(playerBase)-1-counterForAvoidByeDuplication]

				if hadBye[last.UserId] {
					counterForAvoidByeDuplication++
					continue
				} else {
					oddCounter := counterForAvoidByeDuplication%2 == 1
					var possibleOppontentIndex int
					if oddCounter {
						possibleOppontentIndex = len(playerBase) - 1 - (counterForAvoidByeDuplication + 1)
					} else {
						possibleOppontentIndex = len(playerBase) - 1 - (counterForAvoidByeDuplication - 1)
					}
					possibleOpponent := playerBase[possibleOppontentIndex]
					if innerMap, ok := previousOpppo[possibleOpponent.UserId]; ok {
						if val, ok := innerMap[playerBase[len(playerBase)-1].UserId]; ok {
							// Both a and b exist, val contains the value
							if val {
								counterForAvoidByeDuplication++
								continue
							}
						}
					}
					if counterForAvoidByeDuplication > 0 {
						playerBase = append(
							append(
								playerBase[:len(playerBase)-1-counterForAvoidByeDuplication],
								playerBase[len(playerBase)-1],
							),
							playerBase[len(playerBase)-counterForAvoidByeDuplication:len(playerBase)-1]...,
						)
					}
					break
				}
			}
			if counterForAvoidByeDuplication >= len(playerBase) {
				return errors.New("all users had already a bye. Not acceptable situation")
			}
			limit = len(playerBase) - 1
		}

		for i := 0; i < limit; i += 2 {
			if odd && i == limit-1 {
				//last player is bye
				pairs = append(pairs, PairingMatchData{
					UserIdPlayerA: last.UserId,
					UserIdPlayerB: ByePlayerID,
					TournamentId:  tournamentID,
					RoundId:       roundId,
					RoundIndex:    roundIndex,
					IsBye:         true,
					TableIndex:    (len(playerBase) - 1) / 2,
					UserIdWinner:  last.UserId,
				})
			} else {
				pairs = append(pairs, PairingMatchData{
					UserIdPlayerA: playerBase[i].UserId,
					UserIdPlayerB: playerBase[i+1].UserId,
					TournamentId:  tournamentID,
					RoundId:       roundId,
					RoundIndex:    roundIndex,
					IsBye:         false,
					TableIndex:    ((i / 2) + 1),
				})
			}
		}

	} else {
		if odd {
			return errors.New("a top cut round cannot accept a odd playerbase")
		}
		for i := 0; i < limit; i += 2 {
			pairs = append(pairs, PairingMatchData{
				UserIdPlayerA: playerBase[i].UserId,
				UserIdPlayerB: playerBase[len(playerBase)-i-1].UserId,
				TournamentId:  tournamentID,
				RoundId:       roundId,
				RoundIndex:    roundIndex,
				IsBye:         false,
				TableIndex:    ((i / 2) + 1),
			})
		}
	}
	//PAIRING
	//   pairingId
	//   tournament_id
	//   round_id
	//   roundIndex -- ext
	//   roundKind -- ext
	//   roundSize -- ext
	//   playerA (user_id or bye_id)
	//   playerB (user_id or bye_id)
	//   isBye (bool)
	//   tableIndex
	//   winner (user_id or empty if not finished)
	for _, pairing := range pairs {
		_, err2 := app.DB().Insert("pairings", dbx.Params{
			"id_tournament": tournamentID,
			"id_round":      roundId,
			"playerA":       pairing.UserIdPlayerA,
			"playerB":       pairing.UserIdPlayerB,
			"isBye":         pairing.IsBye,
			"tableIndex":    pairing.TableIndex,
			"winner":        pairing.UserIdWinner,
			"created":       time.Now(),
			"updated":       time.Now(),
		}).Execute()
		if err2 != nil {
			return fmt.Errorf("ranking insert failed: %w", err2)
		}
	}
	return nil
}

func executeDBRound(app *pocketbase.PocketBase, tournamentID string, roundKind string, roundIndex int, roundSize int) error {
	err := app.RunInTransaction(func(txApp core.App) error {
		var err2 error
		var result sql.Result

		if roundIndex < 1 {
			return errors.New("round index not acceptable")
		}

		////////////////////////////////////////////////////
		// GENERATION OF ROUND RECORD
		////////////////////////////////////////////////////
		//ROUND
		//   roundId
		//   tournament_id
		//   roundIndex
		//   roundKind (swiss, topcut)
		//   roundSize (only for topcut)
		//   completed (bool)
		//   created
		//   updated
		result, err2 = txApp.DB().Insert("rounds", dbx.Params{
			"id_tournament": tournamentID,
			"roundIndex":    roundIndex,
			"roundKind":     roundKind,
			"completed":     false,
			"roundSize":     roundSize,
			"created":       time.Now(),
			"updated":       time.Now(),
		}).Execute()
		if err2 != nil {
			return fmt.Errorf("round insert failed: %w", err2)
		}
		var roundId string
		roundInserted, err2 := result.RowsAffected()
		if roundInserted == 0 || err2 != nil {
			return fmt.Errorf("round insert failed: %w", err2)
		} else {
			// Get the last inserted ID
			roundRecord, err := app.FindFirstRecordByFilter(
				"rounds",
				"id_tournament = {:tournamentID} && roundIndex = {:roundIndex}",
				dbx.Params{
					"tournamentID": tournamentID,
					"roundIndex":   roundIndex,
				},
			)
			if err != nil {
				return fmt.Errorf("failed to retrieve the inserted round record: %w", err)
			}
			roundId = roundRecord.Id
		}

		usersToPair, prevOpponents, hadBye, err3 := getPlayerList(txApp, tournamentID, roundIndex, roundSize)

		if err3 != nil {
			return fmt.Errorf("something goes wrong in retriving player base: %w", err2)
		}
		////////////////////////////////////////////////////
		// GENERATION OF RANKINGS RECORDS
		////////////////////////////////////////////////////
		err3 = generateRankings(txApp, usersToPair, tournamentID, roundId)
		if err3 != nil {
			return fmt.Errorf("something goes wrong in generating rankings: %w", err2)
		}
		////////////////////////////////////////////////////
		// GENERATION OF PAIRINGS RECORDS
		////////////////////////////////////////////////////
		err3 = generatePairings(txApp, usersToPair, prevOpponents, hadBye, tournamentID, roundKind, roundIndex, roundId)
		if err3 != nil {
			return fmt.Errorf("something goes wrong in generating pairings: %w", err2)
		}

		return nil
	})
	return err
}
func executeDBDeleteRound(app *pocketbase.PocketBase, tournamentID string, roundId string, roundIndex int) error {
	err := app.RunInTransaction(func(txApp core.App) error {
		var err2 error
		var result sql.Result

		result, err2 = txApp.DB().Delete("rounds", dbx.NewExp(
			"id_tournament={:tournamentID} && roundIndex={:roundIndex} && id={:roundId}",
			dbx.Params{
				"tournamentID": tournamentID,
				"roundIndex":   roundIndex,
				"roundId":      roundId,
			},
		)).Execute()
		if err2 != nil {
			return fmt.Errorf("round insert failed: %w", err2)
		}
		roundDeleted, err2 := result.RowsAffected()
		if roundDeleted == 0 || err2 != nil {
			return fmt.Errorf("round delete failed: %w", err2)
		}

		_, err2 = txApp.DB().Delete("rankings", dbx.NewExp(
			"id_tournament={:tournamentID} && roundIndex={:roundIndex} && id_round={:roundId}",
			dbx.Params{
				"tournamentID": tournamentID,
				"roundIndex":   roundIndex,
				"roundId":      roundId,
			},
		)).Execute()
		if err2 != nil {
			return fmt.Errorf("ranking delete failed: %w", err2)
		}

		_, err2 = txApp.DB().Delete("pairings", dbx.NewExp(
			"id_tournament={:tournamentID} && roundIndex={:roundIndex} && id_round={:roundId}",
			dbx.Params{
				"tournamentID": tournamentID,
				"roundIndex":   roundIndex,
				"roundId":      roundId,
			},
		)).Execute()
		if err2 != nil {
			return fmt.Errorf("pairings delete failed: %w", err2)
		}

		return nil
	})
	return err
}
