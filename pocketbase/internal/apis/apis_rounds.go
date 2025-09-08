//round se è topcut avrà anche size 
//round avrà bool completed 
//tournament avrà bool online 
//pairing ha come chiave tournament, round, table


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

type RoundsGenerationRequest struct {
	TournamentID string `json:"id_tournament" validate:"required"`
	RoundKind    string `json:"round_kind" validate:"required"`
	RoundSize    *int   `json:"round_size" validate:"optional"`
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

// Validation context to track request state
type ValidationContext struct {
	App             *pocketbase.PocketBase
	RequesterUserID string
	Data            RoundGenerationRequest
	Tournament      *core.Record
	RoundIndex           int
	RoundSize           int
	StartTime       time.Time
}

type PairingUserData struct {
	UserId             string
	TournamentId       string 
	Points 			   int 
	TB1				   float 
	TB2				   float 
	TB3				   float 
}

type PairingMatchData struct {
	UserIdPlayerA             string
	UserIdPlayerB             string
	TournamentId       string 
	RoundId       string 
	RoundIndex       int 
	IsBye       bool
	TableIndex	int 
	UserIdWinner       string
}

const (
	roundKindTopCut    = "topcut"
	roundKindSwiss       = "swiss"
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
			err := executeDBRound(app, ctx.Data.TournamentID, ctx.Data.RoundKind, ctx.Data.RoundIndex, ctx.Data.RoundSize)
			if err3 != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "ROUND_GENERATION_FAILED",
					Message: err3.Error(),
					Code:    http.StatusBadRequest,
				})
			}

			return e.JSON(http.StatusOK, userDetailSucessResponse)

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
func validateRoundsGenerationRequest(e *core.RequestEvent, app *pocketbase.PocketBase) (*ValidationContext, *ErrorResponse) {
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

	// Step 6: round feasibility
	if err := ctx.validateRoundFeasibility(); err != nil {
		return nil, err
	}

	// Step 6: round concistency
	if err := ctx.validateRoundConsistency(); err != nil {
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
	if ctx.Data.TournamentID == "" || ctx.Data.RoundKind == "" 
		|| (ctx.Data.RoundKind == roundKindTopCut && ctx.Data.RoundSize == nil) {
		return &ErrorResponse{
			Error:   "MISSING_REQUIRED_FIELDS",
			Message: "tournament_id, round_kind are required",
			Code:    http.StatusBadRequest,
		}
	}
	return nil
}

// Round Kind validation
func (ctx *ValidationContext) validateListType() *ErrorResponse {
	validListTypes := []string{roundKindTopCut, roundKindSwiss}
	if !slices.Contains(validListTypes, ctx.Data.ListType) {
		return &ErrorResponse{
			Error:   "INVALID_LIST_TYPE",
			Message: "round_kind must be one of: topcut, swiss",
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

func (ctx *ValidationContext) validateRoundConsistency() *ErrorResponse {
	collectionR, err := app.FindCollectionByNameOrId("rounds")
	if err != nil {
		return fmt.Errorf("failed to find tournaments rounds: %w", err)
	}

	_, err := app.FindFirstRecordByFilter(
		collectionR,
		"id = {:id} && roundIndex = {:roundIndex}", //ORDER BY ROUNDINDEX DESC 
		dbx.Params{
			"id": tournamentID,
			"roundIndex": ctx.RoundIndex,
		},
	)

	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			return fmt.Errorf("The table round is already populated for this index")	
		}
		return fmt.Errorf("failed to check rounds for this tournament: %w", err)
	}


	collectionRR, err := app.FindCollectionByNameOrId("rankings")
	if err != nil {
		return fmt.Errorf("failed to find tournaments rankings: %w", err)
	}

	_, err := app.FindFirstRecordByFilter(
		collectionRR,
		"id = {:id} && roundIndex = {:roundIndex}", //ORDER BY ROUNDINDEX DESC 
		dbx.Params{
			"id": tournamentID,
			"roundIndex": ctx.RoundIndex,
		},
	)

	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			return fmt.Errorf("The table ranking is already populated for this index")	
		}
		return fmt.Errorf("failed to check rounds for this tournament: %w", err)
	}


	collectionP, err := app.FindCollectionByNameOrId("pairings")
	if err != nil {
		return fmt.Errorf("failed to find tournaments pairings: %w", err)
	}

	_, err := app.FindFirstRecordByFilter(
		collectionP,
		"id = {:id} && roundIndex = {:roundIndex}", //ORDER BY ROUNDINDEX DESC 
		dbx.Params{
			"id": tournamentID,
			"roundIndex": ctx.RoundIndex,
		},
	)

	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			return fmt.Errorf("The table pairings is already populated for this index")	
		}
		return fmt.Errorf("failed to check rounds for this tournament: %w", err)
	}

	return nil
}

// Round Feasibility validation 
// calculate the round index based 
// if round is not the first check the previous is ended
// if swiss, check that the last round for tournament is not topcut 
// check that the index of the round is feasible with the number of registered players
func (ctx *ValidationContext) validateRoundFeasibility() *ErrorResponse {
	index, size, err := validateRoundFeasibilityAndComputeIndex(
		ctx.App,
		ctx.Data.TournamentID,
		ctx.Data.RoundKind,
		ctx.Data.RoundSize,
	)
	if err != nil {
		return &ErrorResponse{
			Error:   "ROUND_FEASIBILITY_FAILED",
			Message: err.Error(),
			Code:    http.StatusForbidden,
		}
	}
	ctx.RoundIndex = index
	ctx.RoundSize = size
	return nil
}

// Helper function to send error response
func sendErrorResponse(e *core.RequestEvent, errorResp *ErrorResponse) error {
	statusCode := http.StatusBadRequest
	if errorResp.Code != 0 {
		statusCode = errorResp.Code
	}
	return e.JSON(statusCode, errorResp)
}


// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
// Sub functions for pairing agorithm
// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
func cryptoShuffle(a []string) error {
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
	foundOppo bool
	candidateOppo PairingUserData
	candidateOppoIndex int
	if(stdDirection){
		for candidateOppoIndex := (playerIndex+1); candidateOppoIndex < limit; candidateOppoIndex ++ {
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
		for candidateOppoIndex := (playerIndex+1); candidateOppoIndex > 0; candidateOppoIndex -- {
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

func validateOrganizerUserAndTournamentState(app *pocketbase.PocketBase, userIDRequestor string, tournamentID string) (*core.Record, error) {

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
		return nil, fmt.Errorf("tournament is not in a state that allows enrollments (current state: %s)", state)
	}

	return tournament, nil
}

func validateRoundFeasibilityAndComputeIndex(app *pocketbase.PocketBase, tournamentID string, roundKind string, roundSize int) (int, int, error) {
	var index int;
	var size int;
	var roundKindLastRound string;

	/////////////////////////////////////////////////////////
	//RETRIEVE THE NUM OF REGISTERED PLAYER TO ASSESS IF NEW ROUND COULD BE CREATED
	/////////////////////////////////////////////////////////
	collectionE, err := app.FindCollectionByNameOrId("enrollments")
	if err != nil {
		return index, fmt.Errorf("failed to find tournaments enrollments: %w", err)
	}
	playersNum, err := app.CountRecords(
		collectionE,
		dbx.HashExp{"id_tournament": tournamentID},
		dbx.HashExp{"listKind": "registered"},
	)
	
	if err != nil {
		return index, size, fmt.Errorf("Failed to assesst feasibility for tournament: %w", err2)
	}

	/////////////////////////////////////////////////////////
	//RETRIEVE LAST ROUND FOR THIS TOURNAMENT TO COMPUTE NEW INDEX
	/////////////////////////////////////////////////////////
	collectionR, err := app.FindCollectionByNameOrId("rounds")
	if err != nil {
		return index, fmt.Errorf("failed to find tournaments rounds: %w", err)
	}

	round, err := app.FindFirstRecordByFilter(
		collectionR,
		"id = {:id}", //ORDER BY ROUNDINDEX DESC 
		dbx.Params{
			"id": tournamentID,
		},
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			index = 0;
			size = playersNum;
		}
		return index, size, fmt.Errorf("failed to check rounds for this tournament: %w", err)
	} else {
		index = round.GetInt("roundIndex")
		roundKindLastRound = round.GetString("roundKind")
		roundCompletedLastRound = round.GetBool("completed")
		roundSizeLastRound = round.GetInt("roundSize")
	
		/////////////////////////////////////////////////////////
		//CHECK ROUND IS COMPLETED TO PROCEED
		/////////////////////////////////////////////////////////
		if(!roundCompletedLastRound){
			return index, size, fmt.Errorf("The previous round is not completed yet")
		}
		/////////////////////////////////////////////////////////
		//CHECK NEW SWISS ROUND IS NOT AFTER A TOP CUT ROUND
		/////////////////////////////////////////////////////////
		if(roundKind == roundKindSwiss && roundKindLastRound == roundKindTopCut){
			return index, size, fmt.Errorf("You cannot create a swiss round if you already started a topCut Round earlier")
		}

		collectionRR, err := app.FindCollectionByNameOrId("rankings")
		if err != nil {
			return index, fmt.Errorf("failed to find tournaments rankings: %w", err)
		}
		playersNextRoundNum, err := app.CountRecords(
			collectionRR,
			dbx.HashExp{"id_tournament": tournamentID},
			dbx.HashExp{"roundIndex": index},
			dbx.HashExp{"dropped": false},
		)
		
		if err != nil {
			return index, size, fmt.Errorf("Failed to assesst feasibility for rankings: %w", err2)
		}
		size = playersNextRoundNum;
	}
	/////////////////////////////////////////////////////////
	//playersNum >= 2^index TO ALLOW A NEW SWISS ROUND AND playersNum >= 2 TO ALLOW A NEW TOP CUT ROUND WITH INDEX 0
	//playersNumLastRoundNotDropped >=2 
	/////////////////////////////////////////////////////////
	if(roundKind == roundKindSwiss){
		if playersNum >= (1 << index) {
		    return index++, size, nil
		} else {
			return index, size, fmt.Errorf("Cannot create this swiss round with the player base of this tournament: %w", err) 
		}
	} else {
		if(index == 0){
			if(playersNum >= roundSize){
				return index++, roundSize, nil
			} else {
				return index, roundSize, fmt.Errorf("Cannot create this top cut round with the player base of this tournament: %w", err) 
			}
		} else {
			if(roundKindLastRound == roundKindSwiss && playersNextRoundNum >= roundSize){
				//quello prima era svizzera
				return index++, roundSize, nil;
			} else if(roundKindLastRound == roundKindSwiss && roundSizeLastRound == 2*roundSize){
				//quello prima era top cut 
				return index++, roundSize, nil;
			} else {
				return index, roundSize, fmt.Errorf("Failed to assesst feasibility for tournament")
			}
		}
	}
}

func getPlayerList(app *pocketbase.PocketBase, tournamentID string, roundKind string, roundIndex int, roundSize int) ([]PairingUserData, map[string]map[string]bool, map[string]bool, error) {
	
	var usersToPair []PairingUserData
	prevOpponents = map[string]map[string]bool{}
	hadBye = map[string]bool{}

	add := func(a, b string) {
        if prevOpponents[a] == nil {
            prevOpponents[a] = map[string]bool{}
        }
        prevOpponents[a][b] = true
    }

	if(roundIndex == 1){
		collectionE, err := app.FindCollectionByNameOrId("enrollments")
		if err != nil {
			return nil, fmt.Errorf("failed to find enrollments table: %w", err)
		}

		enrollmnets , err := app.FindRecordsByFilter(
			collectionE,
			"id_tournament = {:tournamentID} && listKind = 'registered'",
			nil,
			nil,
			nil,
			dbx.Params{ 
				"tournamentID": tournamentID 
			}, 
		)

		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				return nil, fmt.Errorf("The table enrollments is not populated: %w", err)	
			}
			return nil, fmt.Errorf("failed to check enrollments for this tournament: %w", err)
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

		rankings , err := app.FindRecordsByFilter(
			collectionRR,
			"id_tournament = {:tournamentID} && roundIndex = {:roundIndex} && dropped = false",
			"points,TB1,TB2,TB3",
			roundSize,
			nil,
			dbx.Params{ 
				"tournamentID": tournamentID,
				"roundIndex": roundIndex
			}, 
		)

		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				return usersToPair, prevOpponents, hadBye, fmt.Errorf("The table rankings is not populated for the selected round: %w", err)	
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

		pairings , err := app.FindRecordsByFilter(
			collectionP,
			"id_tournament = {:tournamentID} && roundIndex < {:roundIndex}",
			nil,
			nil,
			nil,
			dbx.Params{ 
				"tournamentID": tournamentID,
				"roundIndex": roundIndex
			}, 
		)

		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				return usersToPair, prevOpponents, hadBye, fmt.Errorf("The table pairings is not populated for the selected tournament: %w", err)	
			}
			return usersToPair, prevOpponents, hadBye, fmt.Errorf("failed to check pairings for this tournament: %w", err)
		}

		for _, record := range pairings {
		    //add info history and bye 
		    isBye := record.GetInt("points")
		    idPlayerA := record.GetInt("playerA")
		    idPlayerB := record.GetInt("playerB")
		    if isBye {
	            if a != ByePlayerID {
	                hadBye[idPlayerA] = true
	            }
	            if b != ByePlayerID {
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

func generateRankings(app *pocketbase.PocketBase, playerBase []PairingUserData, tournamentID string, roundKind string, roundIndex int) error {
	collectionRR, err := app.FindCollectionByNameOrId("rankings")
	if err != nil {
		return fmt.Errorf("failed to find rankings table: %w", err)
	}

	for _, player := range playerBase {
		result, err2 = txApp.DB().NewQuery(
			`INSERT INTO rankings (id_tournament, roundIndex, roundKind, completed, roundSize, created, updated)
			SELECT {:id_tournament}, {:roundIndex}, {:roundKind}, false, {:roundSize}, datetime('now'), datetime('now')`).
			Bind(dbx.Params{
				"id_tournament": tournamentID,
				"roundIndex": 	 roundIndex,
				"roundKind":     roundKind,
				"roundSize":     roundSize,
			}).
			Execute()

		if err2 != nil {
			return fmt.Errorf("ranking insert failed: %w", err2)
		}
	}

	return nil
}

func generatePairings(app *pocketbase.PocketBase, playerBase []PairingUserData, previousOpppo map[string]map[string]bool, hadBye map[string]bool, tournamentID string, roundKind string, roundIndex int) error {
	odd := len(playerBase)%2 == 1
	var pairs []PairingMatchData
	if roundIndex == 1 {
		// Shuffle players
        if err := cryptoShuffle(playerBase); err != nil {
            return err
        }
	}
	
	limit := len(playerBase)
	if(roundKind == roundKindSwiss){
		if roundIndex == 1 {
			if(odd){
				counterForAvoidByeDuplication=0
				//add bye at the bottom
				for i := 0; i < len(playerBase); i++ {
					last := playerBase[len(playerBase)-1+counterForAvoidByeDuplication]
					if(hadBye[last.UserId]){
						counterForAvoidByeDuplication++
					} else {
						if counterForAvoidByeDuplication > 0 { 
							playerBase = append(playerBase[:i], playerBase[(i+1):]...)
							playerBase = append(playerBase, last)
						}
						break
					}
				}
				if(counterForAvoidByeDuplication >= len(playerBase)) {
					return "All users had already a bye. Not acceptable situation"
				}
				pairs = append(pairs, PairingMatchData{
					UserIdPlayerA: last.UserId, 
					UserIdPlayerB: ByePlayerID, 
					TournamentId: tournamentID, 
					RoundId: ????,
					RoundIndex: roundIndex,
					IsBye: true,
					TableIndex: (len(playerBase)-1)/2,
					UserIdWinner: last.UserId, 
				})
				limit := len(playerBase)-1 
			}

			processed map string bool 
			for i := 0; i < limit; i += 2 {
				observedPlayer := playerBase[i] 
				foundOppo, candidateOppo, candidateOppoIndex := findOpponent(observedPlayer, i, playerBase, previousOpppo, true)

				if(foundOppo){
					playerBase = append(playerBase[:(i+1)], candidateOppo, playerBase[(i+1):(i+1+candidateOppoIndex)], playerBase[(i+candidateOppoIndex+2):]...)
				} else{
					foundOppo, candidateOppo, candidateOppoIndex := findOpponent(observedPlayer, i, playerBase, previousOpppo, false)
					if(foundOppo){
						playerBase = append(playerBase[:candidateOppoIndex], playerBase[candidateOppoIndex+1:i+1], candidateOppo, playerBase[(i+1):]...)
						oddUpSideOppo := candidateOppoIndex%2 == 1
						rebalancePlayerIndex := candidateOppoIndex-1
						foundOppo, candidateOppo, candidateOppoIndex := findOpponent(playerBase[rebalancePlayerIndex], i, playerBase, previousOpppo, true)
						if(!foundOppo){
							return "I cannot avoid rematch in this tournament and in this round"
						} else {
							//playerBase = append(playerBase[:candidateOppoIndex], playerBase[candidateOppoIndex+1:i+1], candidateOppo, playerBase[(i+1):]...)
						}
					} else {
						return "I cannot avoid rematch in this tournament and in this round"
					}
				}





	            pairs = append(pairs, PairingMatchData{
					UserIdPlayerA: playerBase[i].UserId, 
					UserIdPlayerB: playerBase[i+1].UserId, 
					TournamentId: tournamentID, 
					RoundId: ????,
					RoundIndex: roundIndex,
					IsBye: false,
					TableIndex: ((i/2)+1),
				})
	        }
	    } else {

	    }
	} else {
		if(odd){
			return "a top cut round cannot accept a odd playerbase"
		}
		for i := 0; i < limit; i += 2 {
            pairs = append(pairs, PairingMatchData{
				UserIdPlayerA: playerBase[i].UserId, 
				UserIdPlayerB: playerBase[len(playerBase)-i].UserId, 
				TournamentId: tournamentID, 
				RoundId: ????,
				RoundIndex: roundIndex,
				IsBye: false,
				TableIndex: ((i/2)+1),
			})
        }
	}
	
}

func executeDBRound(app *pocketbase.PocketBase, tournamentID string, roundKind string, roundIndex int, roundSize int) error {
	err := app.RunInTransaction(func(txApp core.App) error {
		var err2 error
		var result sql.Result
		
		if(roundIndex<1){
			return "round index not acceptable"
		}

		////////////////////////////////////////////////////
		// GENERATION OF ROUND RECORD
		////////////////////////////////////////////////////
		result, err2 = txApp.DB().NewQuery(
			`INSERT INTO rounds (id_tournament, roundIndex, roundKind, completed, roundSize, created, updated)
			SELECT {:id_tournament}, {:roundIndex}, {:roundKind}, false, {:roundSize}, datetime('now'), datetime('now')`).
			Bind(dbx.Params{
				"id_tournament": tournamentID,
				"roundIndex": 	 roundIndex,
				"roundKind":     roundKind,
				"roundSize":     roundSize,
			}).
			Execute()

		if err2 != nil {
			return fmt.Errorf("round insert failed: %w", err2)
		}

		usersToPair, prevOpponents, hadBye, err3 := getPlayerList(txApp, tournamentID, roundKind, roundIndex, roundSize)

		if err3 != nil {
			return fmt.Errorf("something goes wrong in retriving player base: %w", err2)
		}
		////////////////////////////////////////////////////
		// GENERATION OF RANKINGS RECORDS	
		////////////////////////////////////////////////////
		err3 := generateRankings(txApp, usersToPair, tournamentID, roundKind, roundIndex)
		if err3 != nil {
			return fmt.Errorf("something goes wrong in generating rankings: %w", err2)
		}
		////////////////////////////////////////////////////
		// GENERATION OF PAIRINGS RECORDS
		////////////////////////////////////////////////////
		err3 := generatePairings(txApp, usersToPair, prevOpponents, hadBye, tournamentID, roundKind, roundIndex)
		if err3 != nil {
			return fmt.Errorf("something goes wrong in generating pairings: %w", err2)
		}

		return nil
	})
	return err
}

