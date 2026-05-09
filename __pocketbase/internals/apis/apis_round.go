package apis

import (
	"crypto/rand"
	"database/sql"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"slices"
	"strconv"
	"strings"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

const (
	roundKindTopCut          = "topcut"
	roundKindSwiss           = "swiss"
	registerdEnrollmentsList = "registered"
	ByePlayerID              = "000000000000000"
)

type PlayerData struct {
	UserId string
	Points int
	T1     float64
	T2     float64
	T3     float64
}

type PairingData struct {
	UserIdPlayerA string
	UserIdPlayerB string
	IsBye         bool
	TableIndex    int
	UserIdWinner  string
}

type RoundsRequest struct {
	TournamentID string `json:"id_tournament" validate:"required"`
	RoundKind    string `json:"round_kind" validate:"required"`
	RoundSize    int    `json:"round_size" validate:"optional"`
	RoundIndex   int    `json:"round_index" validate:"optional"`
	RoundId      string `json:"round_id" validate:"optional"`
}

type ValidationContextRound struct {
	App               *pocketbase.PocketBase
	RequesterUserID   string
	Data              RoundsRequest
	RoundIndex        *int
	RoundSize         *int
	PreviousRoundKind *string
}

func CreateRoundAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.POST("/api/tournamentManager/generateRound", func(e *core.RequestEvent) error {
			// Common validation pipeline
			ctx, validationErr := ValidateRoundsGenerationRequest(e, app)
			if validationErr != nil {
				return sendErrorResponse(e, validationErr)
			}

			var roundIndexChecked int
			var roundSizeChecked int
			var roundKindLastRound string
			// Execute update in enrollment with check on capacity if needed
			if ctx.RoundIndex == nil || ctx.RoundSize == nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "ROUND_INDEX_SIZE_COMPUTATION_FAILED",
					Message: fmt.Sprintf("RoundIndex (%s) or roundSize (%s) computation check failed", safeInt(ctx.RoundIndex), safeInt(ctx.RoundSize)),
					Code:    http.StatusBadRequest,
				})
			} else {
				roundIndexChecked = *ctx.RoundIndex
				roundSizeChecked = *ctx.RoundSize
			}
			roundKindLastRound = *ctx.PreviousRoundKind
			err := ExecuteDBRound(app, ctx.Data, roundIndexChecked, roundSizeChecked, roundKindLastRound)
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
			ctx, validationErr := ValidateRoundsDeletionRequest(e, app)
			if validationErr != nil {
				return sendErrorResponse(e, validationErr)
			}

			// Execute update in enrollment with check on capacity if needed
			err := ExecuteDBDeleteRound(app, ctx.Data)
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

func CloseTournamentAPI(app *pocketbase.PocketBase) {
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		se.Router.POST("/api/tournamentManager/closeTournament", func(e *core.RequestEvent) error {
			// Common validation pipeline
			ctx, validationErr := ValidateTournamentClosingRequest(e, app)
			if validationErr != nil {
				return sendErrorResponse(e, validationErr)
			}

			// Execute update in enrollment with check on capacity if needed
			err := ExecuteDBCloseTournament(app, ctx.Data)
			if err != nil {
				return e.JSON(http.StatusBadRequest, ErrorResponse{
					Error:   "TOURNAMENT_CLOSING_FAILED",
					Message: err.Error(),
					Code:    http.StatusBadRequest,
				})
			}

			return e.JSON(http.StatusOK, SuccessResponse{
				Success: true,
				Message: "Tournament closed successfully",
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

// Retrieve the list of eligible users that should be paired
// for each i have also the info of points, t1, t2 and t3
// The list is ordered by points desc, tb1 desc, tb2 desc, tb3 desc, userId asc
func GetEligiblePlayersForPairing(app core.App, tournamentId string, roundIndex int, roundSize int, roundKind string, roundKindLastRound string) ([]PlayerData, map[string]map[string]bool, map[string]bool, error) {
	var playersToPair []PlayerData
	var prevOpponentsMap = map[string]map[string]bool{}
	var hadByeMap = map[string]bool{}

	add := func(a, b string) {
		if prevOpponentsMap[a] == nil {
			prevOpponentsMap[a] = map[string]bool{}
		}
		prevOpponentsMap[a][b] = true
	}

	app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing START tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
	if roundIndex < 1 {
		return playersToPair, prevOpponentsMap, hadByeMap, errors.New("GetEligiblePlayersForPairing roundIndex not acceptable")
	}
	app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing VALIDATED INPUTS tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
	if roundIndex == 1 {
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing CASE roundIndex=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
		// first round, all players with 0 points
		collectionE, err := app.FindCollectionByNameOrId("enrollments")
		if err != nil {
			app.Logger().Error(fmt.Sprintf("GetEligiblePlayersForPairing ERROR roundIndex=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to find enrollments table: %w", err)
		}
		enrollments, err := app.FindRecordsByFilter(
			collectionE,
			"id_tournament = {:tournamentID} && listKind = {:listKind}",
			"",
			-1,
			0,
			dbx.Params{
				"tournamentID": tournamentId,
				"listKind":     registerdEnrollmentsList,
			},
		)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				app.Logger().Error(fmt.Sprintf("GetEligiblePlayersForPairing ERROR roundIndex=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
				return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing the table enrollments is not populated: %w", err)
			}
			app.Logger().Error(fmt.Sprintf("GetEligiblePlayersForPairing ERROR roundIndex=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to check enrollments for this tournament: %w", err)
		}
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing Populate PlayerData roundIndex=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
		for _, record := range enrollments {
			pairing := PlayerData{
				UserId: record.GetString("id_user"),
				Points: 0,
				T1:     0.0,
				T2:     0.0,
				T3:     0.0,
			}
			playersToPair = append(playersToPair, pairing)
		}
	} else {
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing CASE roundIndex!=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
		collectionRR, err := app.FindCollectionByNameOrId("rankings_extended")
		if err != nil {
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to find rankings table: %w", err)
		}
		var rankings []*core.Record
		if roundKind == roundKindSwiss || roundKindLastRound == roundKindSwiss {
			rankings, err = app.FindRecordsByFilter(
				collectionRR,
				"id_tournament = {:tournamentID} && currentRoundIndex = {:roundIndex} && isDrop = false",
				"-points,-T1,-T2,-T3",
				roundSize,
				0,
				dbx.Params{
					"tournamentID": tournamentId,
					"roundIndex":   (roundIndex - 1),
				},
			)
		} else {
			rankings, err = app.FindRecordsByFilter(
				collectionRR,
				"id_tournament = {:tournamentID} && currentRoundIndex = {:roundIndex} && lastWon = true",
				"indexR",
				roundSize,
				0,
				dbx.Params{
					"tournamentID": tournamentId,
					"roundIndex":   (roundIndex - 1),
				},
			)
		}

		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				app.Logger().Error(fmt.Sprintf("GetEligiblePlayersForPairing ERROR roundIndex!=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
				return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing the table rankings is not populated for the selected round: %w", err)
			}
			app.Logger().Error(fmt.Sprintf("GetEligiblePlayersForPairing ERROR roundIndex!=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to check rankings for this tournament: %w", err)
		}
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing Populate PlayerData tournamentId=%s roundIndex=%d roundKind=%s playerLeng=%d", tournamentId, roundIndex, roundKind, len(rankings)))
		for _, record := range rankings {
			points, err1 := strconv.Atoi(strings.Trim(record.GetString("points"), "\""))
			t1, err2 := strconv.ParseFloat(strings.Trim(record.GetString("T1"), "\""), 64)
			t2, err3 := strconv.ParseFloat(strings.Trim(record.GetString("T2"), "\""), 64)
			t3, err4 := strconv.ParseFloat(strings.Trim(record.GetString("T3"), "\""), 64)
			if err1 != nil || err2 != nil || err3 != nil || err4 != nil {
				app.Logger().Error(fmt.Sprintf("GetEligiblePlayersForPairing ERROR roundIndex!=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
				return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to parse points/t1/t2/t3 for player %s: %w %w %w %w", record.GetString("id_user"), err1, err2, err3, err4)
			}

			pairing := PlayerData{
				UserId: strings.Trim(record.GetString("id_user"), "\""),
				Points: points,
				T1:     t1,
				T2:     t2,
				T3:     t3,
			}
			app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing Populate PlayerData tournamentId=%s roundIndex=%d roundKind=%s player=%s %d %f %f %f", tournamentId, roundIndex, roundKind, pairing.UserId, pairing.Points, pairing.T1, pairing.T2, pairing.T3))
			playersToPair = append(playersToPair, pairing)
		}

		//Populating history and bye map
		collectionP, err := app.FindCollectionByNameOrId("pairings_extended")
		if err != nil {
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("failed to find pairings table: %w", err)
		}
		pairings, err := app.FindRecordsByFilter(
			collectionP,
			"id_tournament = {:tournamentID} && roundIndex < {:roundIndex}",
			"",
			-1,
			0,
			dbx.Params{
				"tournamentID": tournamentId,
				"roundIndex":   roundIndex,
			},
		)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				app.Logger().Error(fmt.Sprintf("GetEligiblePlayersForPairing ERROR tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
				return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing the table pairings is not populated for the selected tournament: %w", err)
			}
			app.Logger().Error(fmt.Sprintf("GetEligiblePlayersForPairing ERROR tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to check pairings_extended for this tournament: %w", err)
		}
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing Populate prevOpponentsMap & hadByeMap roundIndex=1 tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
		for _, record := range pairings {
			//add info history and bye
			isBye := record.GetBool("isBye")
			idPlayerA := record.GetString("playerA")
			idPlayerB := record.GetString("playerB")
			if isBye {
				if idPlayerA != ByePlayerID {
					hadByeMap[idPlayerA] = true
				}
				if idPlayerB != ByePlayerID {
					hadByeMap[idPlayerB] = true
				}
			} else {
				add(idPlayerA, idPlayerB)
				add(idPlayerB, idPlayerA)
			}
		}
	}
	app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing END tournamentId=%s roundIndex=%d roundKind=%s", tournamentId, roundIndex, roundKind))
	return playersToPair, prevOpponentsMap, hadByeMap, nil
}

// Shuffle a list of PlayerData
// Fisher-Yates with crypto/rand for reproducibility you can inject a RNG
func ShufflePlayersList(app core.App, players []PlayerData, tournamentId string, roundIndex int) error {
	app.Logger().Debug(fmt.Sprintf("ShufflePlayersList START tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	n := len(players)
	for i := n - 1; i > 0; i-- {
		nBig, err := rand.Int(rand.Reader, big.NewInt(int64(i+1)))
		if err != nil {
			return err
		}
		j := int(nBig.Int64())
		players[i], players[j] = players[j], players[i]
	}
	app.Logger().Debug(fmt.Sprintf("ShufflePlayersList END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	return nil
}

// Create the bye pairing if eligible players are odd
// Returns the pairing created (or nil) and the updated players list
// (without the player that received the bye)
// The player with the lowest points that never had a bye is selected
func CreateByePairingIfNeeded(app core.App, players []PlayerData, hadByeMap map[string]bool, tournamentId string, roundIndex int, roundKind string) ([]PairingData, []PlayerData, error) {
	app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded START tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	if roundKind == roundKindSwiss {
		app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded SWISS CASE tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		if len(players)%2 == 0 {
			//even number of players, no bye needed
			app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded No needed because even number of players tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
			app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
			return []PairingData{}, players, nil
		}
		//odd number of players, bye needed
		//var byePlayerIndex = -1
		for i := len(players) - 1; i >= 0; i-- {
			player := players[i]
			if !hadByeMap[player.UserId] {
				byePairing := PairingData{
					UserIdPlayerA: player.UserId,
					UserIdPlayerB: ByePlayerID,
					IsBye:         true,
					TableIndex:    (len(players)-1)/2 + 1, //last table
					UserIdWinner:  player.UserId,
				}
				//remove player from list
				players = append(players[:i], players[i+1:]...)
				app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded tournamentId=%s roundIndex=%d The player %s receives a bye ", tournamentId, roundIndex, player.UserId))
				app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
				return []PairingData{byePairing}, players, nil
			}
		}
		return []PairingData{}, players, errors.New("CreateByePairingIfNeeded no eligible player for bye found - all players already had a bye")
	} else {
		app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded TOPCAT CASE tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		//comput the minimum power of 2 >= len(players)
		powerOf2 := 1
		for powerOf2 < len(players) {
			powerOf2 *= 2
		}
		numByes := powerOf2 - len(players)

		if numByes == 0 {
			app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded No needed because number of players is power of 2 tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
			app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
			return []PairingData{}, players, nil
		} else if numByes > 0 && roundIndex == 1 {
			app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded %d Byes needed because number of players is not power of 2 tournamentId=%s roundIndex=%d", numByes, tournamentId, roundIndex))
			var byePairings []PairingData
			//for each bye needed create a pairing taking a random player from the player list
			for byeIdx := 0; byeIdx < numByes; byeIdx++ {
				//select random index
				nBig, err := rand.Int(rand.Reader, big.NewInt(int64(len(players))))
				if err != nil {
					return []PairingData{}, players, fmt.Errorf("CreateByePairingIfNeeded something goes wrong in bye random assignment %v", err)
				}
				byePlayerIndex := int(nBig.Int64())
				playerToBye := players[byePlayerIndex]
				byePairing := PairingData{
					UserIdPlayerA: playerToBye.UserId,
					UserIdPlayerB: ByePlayerID,
					IsBye:         true,
					TableIndex:    powerOf2/2 - byeIdx, //last tables
					UserIdWinner:  playerToBye.UserId,
				}
				//remove player from list
				players = append(players[:byePlayerIndex], players[byePlayerIndex+1:]...)
				byePairings = append(byePairings, byePairing)
				app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded tournamentId=%s roundIndex=%d The player %s receives a bye ", tournamentId, roundIndex, playerToBye.UserId))
			}
			app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
			return byePairings, players, nil
		} else {
			return []PairingData{}, players, errors.New("CreateByePairingIfNeeded Byes can be assigned only in first round for topcut rounds")
		}
	}
}

// function that given the list of player return an array containing some sub-array
// where every sub-array is a cluster of players with same points
func ClusterPlayersByPoints(app core.App, players []PlayerData, tournamentId string, roundIndex int) ([][]PlayerData, error) {
	app.Logger().Debug(fmt.Sprintf("ClusterPlayersByPoints START tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	var clusters [][]PlayerData
	if len(players) == 0 {
		app.Logger().Debug(fmt.Sprintf("ClusterPlayersByPoints No players to cluster tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		app.Logger().Debug(fmt.Sprintf("ClusterPlayersByPoints END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		return clusters, nil
	}
	currentPoints := players[0].Points
	var currentCluster []PlayerData
	for _, player := range players {
		if player.Points == currentPoints {
			currentCluster = append(currentCluster, player)
		} else {
			clusters = append(clusters, currentCluster)
			currentCluster = []PlayerData{player}
			currentPoints = player.Points
		}
	}
	//append last cluster
	clusters = append(clusters, currentCluster)
	app.Logger().Debug(fmt.Sprintf("ClusterPlayersByPoints END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	return clusters, nil
}

func PairTopCutPlayers(app core.App, players []PlayerData, tournamentId string, roundIndex int) ([]PairingData, error) {
	var pairings []PairingData
	app.Logger().Debug(fmt.Sprintf("PairTopCutPlayers START tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	for i := 0; i < len(players)/2; i++ {
		pairing := PairingData{
			UserIdPlayerA: players[i].UserId,
			UserIdPlayerB: players[len(players)-1-i].UserId,
			IsBye:         false,
			TableIndex:    0, //to be assigned later
			UserIdWinner:  "",
		}
		pairings = append(pairings, pairing)
	}
	app.Logger().Debug(fmt.Sprintf("PairTopCutPlayers END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	return pairings, nil
}

// function that
//
//		given a cluster of players with same points
//		given a list of lefthovers players from a previous cluster
//	 given the map of previous opponents
//
// does
//
//		if lefthovers is not empty find for each of them a match considering the first player of current cluster that can be paired without rematch
//	 split the remaining players of current cluster in top and bottom half (if odd the top half has one less player)
//	 pair top half with bottom half
//	 count rematches created
//	 if rematches > 0
//			consider each rematch
//			swap the player in secondary position with another player in the same half
//			evaluate if rematch resolved and no new rematch created
//			if rematch resolved break
//	 	else try swapping with other player in the same half
//		 	if after all attempts rematch not resolved
//			do the same swap cycle among first half
//		    if after all attempts rematch not resolved add both players to lefthovers for next cluster
func PairClusterWithRematchHandling(app core.App, cluster []PlayerData, lefthovers []PlayerData, prevOpponentsMap map[string]map[string]bool, tournamentId string, roundIndex int) ([]PairingData, []PlayerData, error) {
	app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling START tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	var pairings []PairingData
	var newLefthovers []PlayerData
	//first handle lefthovers
	app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling Lefthovers management tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	for _, leftover := range lefthovers {
		found := false
		for i, player := range cluster {
			if prevOpponentsMap[leftover.UserId] == nil || !prevOpponentsMap[leftover.UserId][player.UserId] {
				pairing := PairingData{
					UserIdPlayerA: leftover.UserId,
					UserIdPlayerB: player.UserId,
					IsBye:         false,
					TableIndex:    0, //to be assigned later
					UserIdWinner:  "",
				}
				pairings = append(pairings, pairing)
				//remove player from cluster
				cluster = append(cluster[:i], cluster[i+1:]...)
				found = true
				break
			}
		}
		//if not found keep in lefthovers for next cluster
		if !found {
			//keep in lefthovers
			app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling old lefthover %s posponed to new lefthover tournamentId=%s roundIndex=%d", leftover.UserId, tournamentId, roundIndex))
			newLefthovers = append(newLefthovers, leftover)
		}
	}
	//then pair the remaining players in cluster
	clusterSize := len(cluster)
	if clusterSize != 0 {
		app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling Pairing players cluster %d points tournamentId=%s roundIndex=%d", cluster[0].Points, tournamentId, roundIndex))
		halfSize := clusterSize / 2
		topHalf := cluster[:halfSize]
		bottomHalf := cluster[halfSize:]
		//initial pairing
		for i := 0; i < halfSize; i++ {
			pairing := PairingData{
				UserIdPlayerA: topHalf[i].UserId,
				UserIdPlayerB: bottomHalf[i].UserId,
				IsBye:         false,
				TableIndex:    0, //to be assigned later
				UserIdWinner:  "",
			}
			pairings = append(pairings, pairing)
		}
		//check rematches
		rematchIndices := []int{}
		for i, pairing := range pairings {
			if prevOpponentsMap[pairing.UserIdPlayerA] != nil && prevOpponentsMap[pairing.UserIdPlayerA][pairing.UserIdPlayerB] {
				rematchIndices = append(rematchIndices, i)
			}
		}
		app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling Found %d rematches tournamentId=%s roundIndex=%d", len(rematchIndices), tournamentId, roundIndex))
		//try to resolve rematches
		for _, rematchIndex := range rematchIndices {
			resolved := false
			//try swapping in bottom half
			for j := 0; j < len(bottomHalf); j++ {
				app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling The rematch between %s and %s is detected - trying swapping bottom half tournamentId=%s roundIndex=%d", pairings[rematchIndex].UserIdPlayerA, pairings[rematchIndex].UserIdPlayerB, tournamentId, roundIndex))
				if j == rematchIndex {
					continue
				}
				//swap
				rematchResolved := true
				newRematchCreated := false
				if j < halfSize {
					pairings[rematchIndex].UserIdPlayerB, pairings[j].UserIdPlayerB = pairings[j].UserIdPlayerB, pairings[rematchIndex].UserIdPlayerB
					if prevOpponentsMap[pairings[j].UserIdPlayerA] != nil && prevOpponentsMap[pairings[j].UserIdPlayerA][pairings[j].UserIdPlayerB] {
						newRematchCreated = true
					}
				} else {
					pairings[rematchIndex].UserIdPlayerB, bottomHalf[j].UserId = bottomHalf[j].UserId, pairings[rematchIndex].UserIdPlayerB
				}
				//check if rematch resolved and no new rematch created
				if prevOpponentsMap[pairings[rematchIndex].UserIdPlayerA] != nil && prevOpponentsMap[pairings[rematchIndex].UserIdPlayerA][pairings[rematchIndex].UserIdPlayerB] {
					rematchResolved = false
				}

				if rematchResolved && !newRematchCreated {
					resolved = true
					break
				}
				//swap back
				if j < halfSize {
					pairings[rematchIndex].UserIdPlayerB, pairings[j].UserIdPlayerB = pairings[j].UserIdPlayerB, pairings[rematchIndex].UserIdPlayerB
				} else {
					pairings[rematchIndex].UserIdPlayerB, bottomHalf[j].UserId = bottomHalf[j].UserId, pairings[rematchIndex].UserIdPlayerB
				}
			}
			if !resolved {
				app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling The rematch between %s and %s could not be resolved by swapping in bottom half - trying top half tournamentId=%s roundIndex=%d", pairings[rematchIndex].UserIdPlayerA, pairings[rematchIndex].UserIdPlayerB, tournamentId, roundIndex))
				//try swapping in top half
				for j := 0; j < len(topHalf); j++ {
					if j == rematchIndex {
						continue
					}
					//swap
					rematchResolved := true
					newRematchCreated := false
					pairings[rematchIndex].UserIdPlayerA, pairings[j].UserIdPlayerA = pairings[j].UserIdPlayerA, pairings[rematchIndex].UserIdPlayerA
					if prevOpponentsMap[pairings[j].UserIdPlayerA] != nil && prevOpponentsMap[pairings[j].UserIdPlayerA][pairings[j].UserIdPlayerB] {
						newRematchCreated = true
					}
					//check if rematch resolved and no new rematch created
					if prevOpponentsMap[pairings[rematchIndex].UserIdPlayerA] != nil && prevOpponentsMap[pairings[rematchIndex].UserIdPlayerA][pairings[rematchIndex].UserIdPlayerB] {
						rematchResolved = false
					}
					if rematchResolved && !newRematchCreated {
						resolved = true
						break
					}
					//swap back
					pairings[rematchIndex].UserIdPlayerA, pairings[j].UserIdPlayerA = pairings[j].UserIdPlayerA, pairings[rematchIndex].UserIdPlayerA
				}
			}
			if !resolved {
				//could not resolve rematch, add both players to lefthovers
				newLefthovers = append(newLefthovers, PlayerData{UserId: pairings[rematchIndex].UserIdPlayerA})
				newLefthovers = append(newLefthovers, PlayerData{UserId: pairings[rematchIndex].UserIdPlayerB})
				app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling Could not resolve rematch between %s and %s - adding to lefthovers tournamentId=%s roundIndex=%d", pairings[rematchIndex].UserIdPlayerA, pairings[rematchIndex].UserIdPlayerB, tournamentId, roundIndex))
				//remove pairing
				pairings = append(pairings[:rematchIndex], pairings[rematchIndex+1:]...)
			}
		}
		if len(bottomHalf) > len(topHalf) {
			app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling This cluster has odd number of players - adding last player of bottom half to lefthovers %s tournamentId=%s roundIndex=%d", bottomHalf[len(bottomHalf)-1].UserId, tournamentId, roundIndex))
			newLefthovers = append(newLefthovers, bottomHalf[len(bottomHalf)-1])
		}
		for _, pairing := range pairings {
			app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling Created pairing %s vs %s tournamentId=%s roundIndex=%d", pairing.UserIdPlayerA, pairing.UserIdPlayerB, tournamentId, roundIndex))
		}
	}

	app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	return pairings, newLefthovers, nil
}

// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
// Sub functions for checks
// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
// Common validation pipeline
func ValidateRoundsGenerationRequest(e *core.RequestEvent, app *pocketbase.PocketBase) (*ValidationContextRound, *ErrorResponse) {
	ctx, err := ValidateRoundsRequest(e, app, false)
	if err != nil {
		return nil, err
	}

	// Step 4: round feasibility
	if err := ctx.ValidateRoundFeasibilityAndComputeIndex(); err != nil {
		return nil, err
	}

	// Step 5: round concistency
	if err := ctx.ValidateRoundConsistency(); err != nil {
		return nil, err
	}
	return ctx, nil
}
func ValidateRoundsDeletionRequest(e *core.RequestEvent, app *pocketbase.PocketBase) (*ValidationContextRound, *ErrorResponse) {
	ctx, err := ValidateRoundsRequest(e, app, true)
	if err != nil {
		return nil, err
	}

	// Step 4: round feasibility
	if err := ctx.ValidateRoundDelFeasibilityAndComputeIndex(); err != nil {
		return nil, err
	}

	return ctx, nil
}
func ValidateTournamentClosingRequest(e *core.RequestEvent, app *pocketbase.PocketBase) (*ValidationContextRound, *ErrorResponse) {
	ctx, err := ValidateRoundsRequest(e, app, true)
	if err != nil {
		return nil, err
	}

	// Step 4: round feasibility
	if err := ctx.ValidateRoundDelFeasibilityAndComputeIndex(); err != nil {
		return nil, err
	}

	// Step 4: round feasibility
	if err := ctx.ValidateClosingFeasibility(); err != nil {
		return nil, err
	}

	return ctx, nil
}
func ValidateRoundsRequest(e *core.RequestEvent, app *pocketbase.PocketBase, delFlag bool) (*ValidationContextRound, *ErrorResponse) {
	ctx := &ValidationContextRound{
		App: app,
	}

	// Step 1: Authentication check
	if err := ctx.ValidateAuthentication(e); err != nil {
		return nil, err
	}

	// Step 2: Request body parsing and validation
	if err := ctx.ValidateRequestBody(e, delFlag); err != nil {
		return nil, err
	}

	// Step 3: Organizer and tournament state validation
	if err := ctx.ValidateOrganizerAndTournament(); err != nil {
		return nil, err
	}

	return ctx, nil
}

// Authentication validation
func (ctx *ValidationContextRound) ValidateAuthentication(e *core.RequestEvent) *ErrorResponse {
	ctx.App.Logger().Debug("ValidateAuthentication START tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
	authRecord := e.Auth
	if authRecord == nil {
		ctx.App.Logger().Error("ValidateAuthentication END tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
		return &ErrorResponse{
			Error:   "UNAUTHORIZED",
			Message: "ValidateAuthentication: Authentication required",
			Code:    http.StatusUnauthorized,
		}
	}
	ctx.RequesterUserID = authRecord.Id
	ctx.App.Logger().Debug("ValidateAuthentication END tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
	return nil
}

func (ctx *ValidationContextRound) ValidateRequestBody(e *core.RequestEvent, delFlag bool) *ErrorResponse {
	ctx.App.Logger().Debug("ValidateRequestBody START tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
	if err := e.BindBody(&ctx.Data); err != nil {
		ctx.App.Logger().Error("ValidateRequestBody ERROR tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
		return &ErrorResponse{
			Error:   "INVALID_REQUEST",
			Message: fmt.Sprintf("ValidateRequestBody: Invalid request body format %v", err),
			Code:    http.StatusBadRequest,
		}
	}
	if ctx.Data.TournamentID == "" || ctx.Data.RoundKind == "" || (ctx.Data.RoundKind == roundKindTopCut && ctx.Data.RoundSize == 0) {
		ctx.App.Logger().Error("ValidateRequestBody ERROR tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
		return &ErrorResponse{
			Error:   "MISSING_REQUIRED_FIELDS",
			Message: "ValidateRequestBody: tournament_id, round_kind are required (and roundSize if round_kind is topcut)",
			Code:    http.StatusBadRequest,
		}
	}
	if delFlag {
		if ctx.Data.RoundIndex == 0 || ctx.Data.RoundId == "" {
			ctx.App.Logger().Error("ValidateRequestBody ERROR tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
			return &ErrorResponse{
				Error:   "MISSING_REQUIRED_FIELDS",
				Message: "ValidateRequestBody: round_index, round_id are required for round deletion",
				Code:    http.StatusBadRequest,
			}
		}
	}
	validRoundKind := []string{roundKindTopCut, roundKindSwiss}
	if !slices.Contains(validRoundKind, ctx.Data.RoundKind) {
		ctx.App.Logger().Error("ValidateRequestBody ERROR tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
		return &ErrorResponse{
			Error:   "INVALID_LIST_TYPE",
			Message: "ValidateRequestBody: round_kind must be one of: topcut, swiss",
			Code:    http.StatusBadRequest,
		}
	}
	ctx.App.Logger().Debug("ValidateRequestBody END tournamentId=TOBEDEFINED roundIndex=TOBEDEFINED")
	return nil
}

// Organizer and tournament validation
func (ctx *ValidationContextRound) ValidateOrganizerAndTournament() *ErrorResponse {
	ctx.App.Logger().Debug(fmt.Sprintf("ValidateOrganizerAndTournament START tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	//check if user is an organizer
	collectionU, err := ctx.App.FindCollectionByNameOrId("users")
	if err != nil {
		return &ErrorResponse{
			Error:   "ORGANIZER_VERIFICATION_FAILED",
			Message: fmt.Sprintf("ValidateOrganizerAndTournament: failed to find users collection: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	user, err := ctx.App.FindRecordById(collectionU, ctx.RequesterUserID)
	if err != nil {
		return &ErrorResponse{
			Error:   "ORGANIZER_VERIFICATION_FAILED",
			Message: fmt.Sprintf("ValidateOrganizerAndTournament: caller user not found: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	organizer := user.GetBool("organizer")
	if !organizer {
		return &ErrorResponse{
			Error:   "ORGANIZER_VERIFICATION_FAILED",
			Message: fmt.Sprintf("ValidateOrganizerAndTournament: access denied: user is not an organizer tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}

	//check if user is the organizer of the providerd tournament
	collectionT, err := ctx.App.FindCollectionByNameOrId("tournaments")
	if err != nil {
		return &ErrorResponse{
			Error:   "ORGANIZER_VERIFICATION_FAILED",
			Message: fmt.Sprintf("ValidateOrganizerAndTournament: failed to find tournaments collection: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	tournament, err := ctx.App.FindFirstRecordByFilter(
		collectionT,
		"id = {:id}",
		dbx.Params{
			"id": ctx.Data.TournamentID,
		},
	)
	if err != nil {
		return &ErrorResponse{
			Error:   "ORGANIZER_VERIFICATION_FAILED",
			Message: fmt.Sprintf("ValidateOrganizerAndTournament: tournament not found: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	tournamentOwnerID := tournament.GetString("id_owner")
	if tournamentOwnerID != ctx.RequesterUserID {
		return &ErrorResponse{
			Error:   "ORGANIZER_VERIFICATION_FAILED",
			Message: fmt.Sprintf("ValidateOrganizerAndTournament: access denied: user is not the owner of the tournament tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}

	//check if tournament is in a state that allows modifications
	state := tournament.GetString("state")
	if state != "ongoing" {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateOrganizerAndTournament ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ORGANIZER_VERIFICATION_FAILED",
			Message: fmt.Sprintf("ValidateOrganizerAndTournament: tournament is not in a state that allows round gen (current state: %s) tournamentId=%s roundIndex=%d", state, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	ctx.App.Logger().Debug(fmt.Sprintf("ValidateOrganizerAndTournament END tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	return nil
}

func (ctx *ValidationContextRound) ValidateRoundDelFeasibilityAndComputeIndex() *ErrorResponse {
	ctx.App.Logger().Debug(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex START tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	/////////////////////////////////////////////////////////
	//CHECK IF ROUND EXISTS AND BELONGS TO THE TOURNAMENT PROVIDED
	/////////////////////////////////////////////////////////
	collectionR, err := ctx.App.FindCollectionByNameOrId("rounds")
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_DEL_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to find tournaments rounds: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	round, err := ctx.App.FindRecordById(collectionR, ctx.Data.RoundId)
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_DEL_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to find the round: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	if round.GetString("id_tournament") != ctx.Data.TournamentID {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_DEL_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: the round does not belong to the provided tournament tournamentId=%s roundIndex=%d error=%v", ctx.Data.TournamentID, ctx.Data.RoundIndex, err),
			Code:    http.StatusForbidden,
		}
	}
	if round.GetString("roundKind") != ctx.Data.RoundKind {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_DEL_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: the round does not have the provided roundKind tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	if round.GetInt("roundIndex") != ctx.Data.RoundIndex {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_DEL_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: the round does not have the provided roundIndex tournamentId=%s roundIndex=%d error=%v", ctx.Data.TournamentID, ctx.Data.RoundIndex, err),
			Code:    http.StatusForbidden,
		}
	}

	/////////////////////////////////////////////////////////
	//CHECK IF ROUND IS THE LAST ONE FOR THIS TOURNAMENT
	/////////////////////////////////////////////////////////
	rounds, err := ctx.App.FindRecordsByFilter(
		collectionR,
		"id_tournament = {:tournamentID}",
		"-roundIndex", //ORDER BY ROUNDINDEX DESC
		1,
		0,
		dbx.Params{
			"tournamentID": ctx.Data.TournamentID,
		},
	)
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_DEL_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to check rounds for this tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}

	} else {
		indexString := rounds[0].GetString("roundIndex")
		index, err := strconv.Atoi(indexString)
		if err != nil {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_DEL_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to parse roundIndex of last round to int for tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
		if index != ctx.Data.RoundIndex {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_DEL_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: only the last round can be deleted tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
	}
	ctx.App.Logger().Debug(fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex END tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	return nil
}

func (ctx *ValidationContextRound) ValidateRoundFeasibilityAndComputeIndex() *ErrorResponse {
	var index int
	var size int
	var roundKindLastRound string
	var roundSizeLastRound int
	var playersNextRoundNum int
	//enrollments
	//round_extended
	//rankings_extended

	ctx.App.Logger().Debug(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex START tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	/////////////////////////////////////////////////////////
	//RETRIEVE THE NUM OF REGISTERED PLAYER TO ASSESS IF NEW ROUND COULD BE CREATED
	/////////////////////////////////////////////////////////
	collectionE, err := ctx.App.FindCollectionByNameOrId("enrollments")
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to find tournaments enrollments: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	playersNum, err := ctx.App.CountRecords(
		collectionE,
		dbx.HashExp{"id_tournament": ctx.Data.TournamentID},
		dbx.HashExp{"listKind": "registered"},
	)
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex:failed to assesst feasibility for tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}

	/////////////////////////////////////////////////////////
	//RETRIEVE LAST ROUND FOR THIS TOURNAMENT TO COMPUTE NEW INDEX
	/////////////////////////////////////////////////////////
	collectionR, err := ctx.App.FindCollectionByNameOrId("rounds_extended")
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to find tournaments rounds_extended: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	round, err := ctx.App.FindRecordsByFilter(
		collectionR,
		"id_tournament = {:tournamentID}",
		"-roundIndex", //ORDER BY ROUNDINDEX DESC
		1,
		0,
		dbx.Params{
			"tournamentID": ctx.Data.TournamentID,
		},
	)
	if err != nil || round == nil || len(round) == 0 {
		if err != nil && !errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to check rounds_extended for this tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		} else {
			index = 0
			size = int(playersNum)
			ctx.App.Logger().Debug(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex Nessun round presente, si procede con la creazione del round 0 tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		}
	} else {
		indexString := round[0].GetString("roundIndex") //convertion to int
		index, err = strconv.Atoi(indexString)
		if err != nil {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to parse roundIndex of last round to int for tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
		roundKindLastRound = strings.Trim(round[0].GetString("roundKind"), "\"")
		roundCompletedLastRoundString := round[0].GetString("completed")
		roundCompletedLastRound, err := strconv.ParseBool(roundCompletedLastRoundString)
		if err != nil {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to parse completed of last round to bool for tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
		roundSizeLastRoundString := round[0].GetString("roundSize")
		roundSizeLastRound, err = strconv.Atoi(roundSizeLastRoundString)
		if err != nil {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to parse roundSize of last round to int for tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}

		/////////////////////////////////////////////////////////
		//CHECK ROUND IS COMPLETED TO PROCEED
		/////////////////////////////////////////////////////////
		if !roundCompletedLastRound {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: the previous round is not completed yet tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
		/////////////////////////////////////////////////////////
		//CHECK NEW SWISS ROUND IS NOT AFTER A TOP CUT ROUND
		/////////////////////////////////////////////////////////
		if ctx.Data.RoundKind == roundKindSwiss && roundKindLastRound == roundKindTopCut {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: you cannot create a swiss round if you already started a topCut Round earlier tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}

		collectionRR, err := ctx.App.FindCollectionByNameOrId("rankings_extended")
		if err != nil {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to find tournaments rankings_extended: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
		playersNextRoundNum64, err := ctx.App.CountRecords(
			collectionRR,
			dbx.HashExp{"id_tournament": ctx.Data.TournamentID},
			dbx.HashExp{"currentRoundIndex": index},
			dbx.HashExp{"isDrop": false},
		)
		if err != nil {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: failed to assesst feasibility for rankings_extended: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
		playersNextRoundNum = int(playersNextRoundNum64)
		size = playersNextRoundNum
	}
	/////////////////////////////////////////////////////////
	//playersNum >= 2^index TO ALLOW A NEW SWISS ROUND AND playersNum >= 2 TO ALLOW A NEW TOP CUT ROUND WITH INDEX 0
	//playersNumLastRoundNotDropped >=2
	/////////////////////////////////////////////////////////
	if ctx.Data.RoundKind == roundKindSwiss {
		if int(playersNum) >= (1 << index) {
			index++
		} else {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUND_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: cannot create this swiss round with the player base of this tournament (not enough player): tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
	} else {
		size = ctx.Data.RoundSize
		if index == 0 {
			if int(playersNum) >= ctx.Data.RoundSize {
				index++
			} else {
				ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
				return &ErrorResponse{
					Error:   "ROUND_FEASIBILITY_FAILED",
					Message: fmt.Sprintf("ValidateRoundDelFeasibilityAndComputeIndex: cannot create this top cut round with the player base of this tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
					Code:    http.StatusForbidden,
				}
			}
		} else {
			if roundKindLastRound == roundKindSwiss && playersNextRoundNum >= ctx.Data.RoundSize {
				//quello prima era svizzera
				index++
			} else if roundKindLastRound == roundKindTopCut && roundSizeLastRound == 2*(ctx.Data.RoundSize) {
				//quello prima era top cut
				index++
			} else {
				ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex ERROR tournamentId=%s roundIndex=%d roundKindLastRound=%s, playersNextRoundNum=%d, roundSizeLastRound=%d LastRoundIndex=%d newRoundSize=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex, roundKindLastRound, playersNextRoundNum, roundSizeLastRound, index, ctx.Data.RoundSize))
				return &ErrorResponse{
					Error:   "ROUND_FEASIBILITY_FAILED",
					Message: fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex: failed to assesst feasibility for tournament: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
					Code:    http.StatusForbidden,
				}
			}
		}
	}
	ctx.App.Logger().Debug(fmt.Sprintf("ValidateRoundFeasibilityAndComputeIndex END tournamentId=%s roundIndex=%d NewRoundSize=%d NewRoundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex, size, index))
	ctx.RoundSize = &size
	ctx.RoundIndex = &index
	ctx.PreviousRoundKind = &roundKindLastRound
	return nil
}

func (ctx *ValidationContextRound) ValidateRoundConsistency() *ErrorResponse {
	ctx.App.Logger().Debug(fmt.Sprintf("ValidateRoundConsistency START tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	collectionR, err := ctx.App.FindCollectionByNameOrId("rounds")
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundConsistency ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUNDS_COLLECTION_NOT_FOUND",
			Message: fmt.Sprintf("failed to find tournaments rounds: %v", err),
			Code:    http.StatusInternalServerError,
		}
	}

	_, err = ctx.App.FindFirstRecordByFilter(
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
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundConsistency ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "ROUNDS_CHECK_FAILED",
				Message: fmt.Sprintf("failed to check rounds for this tournament: %v", err),
				Code:    http.StatusInternalServerError,
			}
		}
	} else {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundConsistency ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "ROUND_ALREADY_POPULATED",
			Message: fmt.Sprintf("The round is already populated for this roundIndex %s %s", safeInt(ctx.RoundIndex), ctx.Data.TournamentID),
			Code:    http.StatusBadRequest,
		}
	}

	collectionRR, err := ctx.App.FindCollectionByNameOrId("rankings")
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundConsistency ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "RANKINGS_COLLECTION_NOT_FOUND",
			Message: fmt.Sprintf("failed to find tournaments rankings: %v", err),
			Code:    http.StatusInternalServerError,
		}
	}

	_, err = ctx.App.FindFirstRecordByFilter(
		collectionRR,
		"id_tournament = {:tournamentID} && id_round.roundIndex = {:roundIndex}", //ORDER BY ROUNDINDEX DESC
		dbx.Params{
			"tournamentID": ctx.Data.TournamentID,
			"roundIndex":   ctx.RoundIndex,
		},
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			//ok
		} else {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundConsistency ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "RANKINGS_CHECK_FAILED",
				Message: fmt.Sprintf("failed to check rankings for this roundIndex (%s) tournamentId (%s): %v", safeInt(ctx.RoundIndex), ctx.Data.TournamentID, err),
				Code:    http.StatusInternalServerError,
			}
		}
	}

	collectionP, err := ctx.App.FindCollectionByNameOrId("pairings")
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundConsistency ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "PAIRINGS_COLLECTION_NOT_FOUND",
			Message: fmt.Sprintf("failed to find tournaments pairings: %v", err),
			Code:    http.StatusInternalServerError,
		}
	}

	_, err = ctx.App.FindFirstRecordByFilter(
		collectionP,
		"id_tournament = {:tournamentID} && id_round.roundIndex = {:roundIndex}", //ORDER BY ROUNDINDEX DESC
		dbx.Params{
			"tournamentID": ctx.Data.TournamentID,
			"roundIndex":   ctx.RoundIndex,
		},
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
			//ok
		} else {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateRoundConsistency ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "PAIRINGS_CHECK_FAILED",
				Message: fmt.Sprintf("failed to check pairings for this roundIndex (%s) tournamentId (%s): %v", safeInt(ctx.RoundIndex), ctx.Data.TournamentID, err),
				Code:    http.StatusInternalServerError,
			}
		}
	}

	ctx.App.Logger().Debug(fmt.Sprintf("ValidateRoundConsistency END tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	return nil
}

func (ctx *ValidationContextRound) ValidateClosingFeasibility() *ErrorResponse {
	ctx.App.Logger().Debug(fmt.Sprintf("ValidateClosingFeasibility START tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	collectionR, err := ctx.App.FindCollectionByNameOrId("rounds_extended")
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateClosingFeasibility ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "TOURNAMENT_CLOSING_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateClosingFeasibility: failed to find table rounds_extended: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	}
	round, err := ctx.App.FindRecordById(collectionR, ctx.Data.RoundId)
	if err != nil {
		ctx.App.Logger().Error(fmt.Sprintf("ValidateClosingFeasibility ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
		return &ErrorResponse{
			Error:   "TOURNAMENT_CLOSING_FEASIBILITY_FAILED",
			Message: fmt.Sprintf("ValidateClosingFeasibility: failed to find the round: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
			Code:    http.StatusForbidden,
		}
	} else {
		completedString := round.GetString("completed")
		completed, err := strconv.ParseBool(completedString)
		if err != nil {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateClosingFeasibility ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "TOURNAMENT_CLOSING_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateClosingFeasibility: failed to parse completed of the round to bool: %v tournamentId=%s roundIndex=%d", err, ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
		if !completed {
			ctx.App.Logger().Error(fmt.Sprintf("ValidateClosingFeasibility ERROR tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
			return &ErrorResponse{
				Error:   "TOURNAMENT_CLOSING_FEASIBILITY_FAILED",
				Message: fmt.Sprintf("ValidateClosingFeasibility: the round is not completed yet tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex),
				Code:    http.StatusForbidden,
			}
		}
	}
	ctx.App.Logger().Debug(fmt.Sprintf("ValidateClosingFeasibility END tournamentId=%s roundIndex=%d", ctx.Data.TournamentID, ctx.Data.RoundIndex))
	return nil
}

// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
// Sub functions for executions
// //////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////
func ExecuteDBRound(app *pocketbase.PocketBase, Data RoundsRequest, roundIndexChecked int, roundSizeChecked int, roundKindLastRound string) error {
	app.Logger().Debug(fmt.Sprintf("ExecuteDBRound START tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
	err := app.RunInTransaction(func(txApp core.App) error {

		//#####################################
		//INSERT ROUND RECORD
		//#####################################
		app.Logger().Debug(fmt.Sprintf("ExecuteDBRound ROUND CREATION tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
		rounds, err := txApp.FindCollectionByNameOrId("rounds")
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
			return fmt.Errorf("ExecuteDBRound: failed to find rounds table: %w", err)
		}
		record := core.NewRecord(rounds)
		record.Set("id_tournament", Data.TournamentID)
		record.Set("roundIndex", roundIndexChecked)
		record.Set("roundSize", roundSizeChecked)
		record.Set("roundKind", Data.RoundKind)
		if err := txApp.Save(record); err != nil {
			return fmt.Errorf("ExecuteDBRound: round insert failed: %w", err)
		}
		roundId := record.Id
		app.Logger().Debug(fmt.Sprintf("ExecuteDBRound ROUND CREATION tournamentId=%s roundIndex=%d roundId=%s", Data.TournamentID, roundIndexChecked, roundId))
		pairingsList := make([]PairingData, 0)

		//#####################################
		//DEFINE PLAYERS TO BE PART OF THE ROUND
		//#####################################
		playersList, historyPairings, historyBye, err := GetEligiblePlayersForPairing(txApp, Data.TournamentID, roundIndexChecked, roundSizeChecked, Data.RoundKind, roundKindLastRound)
		app.Logger().Debug(fmt.Sprintf("ExecuteDBRound INFO tournamentId=%s roundIndex=%d playerlist=%v historyPairings=%v historyBye=%v", Data.TournamentID, roundIndexChecked, playersList, historyPairings, historyBye))
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
			return fmt.Errorf("ExecuteDBRound: failed to retrieve eligible players for pairing: %w", err)
		}

		//#####################################
		//INSERT PLAYER RANKING RECORDS
		//#####################################
		app.Logger().Debug(fmt.Sprintf("ExecuteDBRound RANKING CREATION tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
		rankings, err := txApp.FindCollectionByNameOrId("rankings")
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
			return fmt.Errorf("ExecuteDBRound: failed to find rankings table: %w", err)
		}
		for i, player := range playersList {
			record := core.NewRecord(rankings)
			record.Set("id_tournament", Data.TournamentID)
			record.Set("id_round", roundId)
			record.Set("id_user", strings.Trim(player.UserId, "\""))
			record.Set("indexR", (i + 1))
			if err := txApp.Save(record); err != nil {
				return fmt.Errorf("ExecuteDBRound: ranking insert failed: %w", err)
			}
		}

		//#####################################
		//SHUFFLE PLAYERS LIST IF FIRST ROUND
		//#####################################
		if roundIndexChecked == 1 {
			err := ShufflePlayersList(txApp, playersList, Data.TournamentID, roundIndexChecked)
			if err != nil {
				app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
				return fmt.Errorf("ExecuteDBRound: failed to shuffle players list for first round: %w", err)
			}
		}

		//#####################################
		//CREATE BYE PAIRING IF NEEDED
		//#####################################
		app.Logger().Debug(fmt.Sprintf("ExecuteDBRound BYE CREATION tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
		var byePairingData []PairingData
		byePairingData, playersList, err = CreateByePairingIfNeeded(txApp, playersList, historyBye, Data.TournamentID, roundIndexChecked, Data.RoundKind)
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
			return fmt.Errorf("ExecuteDBRound: failed to create bye pairing: %w", err)
		} else {
			pairingsList = append(pairingsList, byePairingData...)
		}

		switch Data.RoundKind {
		case roundKindSwiss:
			//#####################################
			//CLUSTERIZE PLAYERS
			//#####################################
			clusterPlayers, err := ClusterPlayersByPoints(txApp, playersList, Data.TournamentID, roundIndexChecked)
			if err != nil {
				app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
				return fmt.Errorf("ExecuteDBRound: failed to clusterize players: %w", err)
			}

			//#####################################
			//CREATE PAIRINGS WITH REMATCH HANDLING
			//#####################################
			currentLefthovers := make([]PlayerData, 0)
			for _, cluster := range clusterPlayers {
				app.Logger().Debug(fmt.Sprintf("ExecuteDBRound PAIRINGS CREATION FOR CLUSTER with %d points tournamentId=%s roundIndex=%d clusterSize=%d lefthoverSize=%d", cluster[0].Points, Data.TournamentID, roundIndexChecked, len(cluster), len(currentLefthovers)))
				pairings, newLefthovers, err := PairClusterWithRematchHandling(txApp, cluster, currentLefthovers, historyPairings, Data.TournamentID, roundIndexChecked)
				if err != nil {
					app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
					return fmt.Errorf("ExecuteDBRound: failed to create pairings for cluster with %d points: %w", cluster[0].Points, err)
				} else {
					pairingsList = append(pairingsList, pairings...)
					currentLefthovers = newLefthovers
				}
			}
			if len(currentLefthovers) > 0 {
				app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d lefthoversSize=%d", Data.TournamentID, roundIndexChecked, len(currentLefthovers)))
				return fmt.Errorf("ExecuteDBRound: failed to create pairings -- lefthover remained")
			}

		case roundKindTopCut:
			//#####################################
			//CREATE PAIRINGS WITH OPPOSITE RANKING POSITIONS
			//#####################################
			app.Logger().Debug(fmt.Sprintf("ExecuteDBRound PAIRINGS CREATION FOR TOPCUT tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
			pairings, err := PairTopCutPlayers(txApp, playersList, Data.TournamentID, roundIndexChecked)
			if err != nil {
				app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
				return fmt.Errorf("ExecuteDBRound: failed to create top cut pairings: %w", err)
			} else {
				pairingsList = append(pairingsList, pairings...)
			}
		default:
			app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
			return fmt.Errorf("ExecuteDBRound: unknown roundKind %s tournamentId=%s roundIndex=%d", Data.RoundKind, Data.TournamentID, roundIndexChecked)
		}

		app.Logger().Debug(fmt.Sprintf("ExecuteDBRound PAIRINGS CREATION tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
		pairings, err := txApp.FindCollectionByNameOrId("pairings")
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
			return fmt.Errorf("ExecuteDBRound: failed to find pairings table: %w", err)
		}
		tableIndex := 1
		for i := range pairingsList {
			if pairingsList[i].TableIndex == 0 {
				pairingsList[i].TableIndex = tableIndex
				tableIndex++
			}
		}
		for _, pairing := range pairingsList {
			record := core.NewRecord(pairings)
			record.Set("id_tournament", Data.TournamentID)
			record.Set("id_round", roundId)
			record.Set("playerA", strings.Trim(pairing.UserIdPlayerA, "\""))
			record.Set("playerB", strings.Trim(pairing.UserIdPlayerB, "\""))
			record.Set("isBye", pairing.IsBye)
			record.Set("tableIndex", pairing.TableIndex)
			record.Set("winner", strings.Trim(pairing.UserIdWinner, "\""))
			if err := txApp.Save(record); err != nil {
				return fmt.Errorf("ExecuteDBRound: ranking insert failed: %w", err)
			}
		}
		app.Logger().Debug(fmt.Sprintf("ExecuteDBRound ALL PAIRINGS CREATED SUCCESSFULLY tournamentId=%s roundIndex=%d totalPairings=%d", Data.TournamentID, roundIndexChecked, len(pairingsList)))
		return nil
	})
	if err != nil {
		app.Logger().Error(fmt.Sprintf("ExecuteDBRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
		return fmt.Errorf("ExecuteDBRound: failed to transaction: %w", err)
	}

	app.Logger().Debug(fmt.Sprintf("ExecuteDBRound END tournamentId=%s roundIndex=%d", Data.TournamentID, roundIndexChecked))
	return err
}

func ExecuteDBDeleteRound(app *pocketbase.PocketBase, Data RoundsRequest) error {
	app.Logger().Debug(fmt.Sprintf("ExecuteDBDeleteRound START tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
	err := app.RunInTransaction(func(txApp core.App) error {
		//#####################################
		//CLEAN PAIRINGS
		//#####################################
		_, err := txApp.DB().Delete("pairings", dbx.NewExp(
			"id_tournament={:tournamentID} AND id_round={:roundId}",
			dbx.Params{
				"tournamentID": Data.TournamentID,
				"roundId":      Data.RoundId,
			},
		)).Execute()
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBDeleteRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
			return fmt.Errorf("ExecuteDBDeleteRound: failed to delete pairing records: %v", err)
		}

		//#####################################
		//CLEAN RANKINGS
		//#####################################
		_, err = txApp.DB().Delete("rankings", dbx.NewExp(
			"id_tournament={:tournamentID} AND id_round={:roundId}",
			dbx.Params{
				"tournamentID": Data.TournamentID,
				"roundId":      Data.RoundId,
			},
		)).Execute()
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBDeleteRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
			return fmt.Errorf("ExecuteDBDeleteRound: failed to delete rankings records: %v", err)
		}

		//#####################################
		//CLEAN ROUNDS
		//#####################################
		_, err = txApp.DB().Delete("rounds", dbx.NewExp(
			"id_tournament={:tournamentID} AND roundIndex={:roundIndex} AND id={:roundId}",
			dbx.Params{
				"tournamentID": Data.TournamentID,
				"roundIndex":   Data.RoundIndex,
				"roundId":      Data.RoundId,
			},
		)).Execute()
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBDeleteRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
			return fmt.Errorf("ExecuteDBDeleteRound: failed to delete round record: %v", err)
		}

		return nil
	})
	if err != nil {
		app.Logger().Error(fmt.Sprintf("ExecuteDBDeleteRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
		return fmt.Errorf("ExecuteDBDeleteRound: failed to transaction: %v", err)
	}

	app.Logger().Debug(fmt.Sprintf("ExecuteDBDeleteRound END tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
	return nil
}

func ExecuteDBCloseTournament(app *pocketbase.PocketBase, Data RoundsRequest) error {
	app.Logger().Debug(fmt.Sprintf("ExecuteDBCloseRound START tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
	err := app.RunInTransaction(func(txApp core.App) error {
		collectionRR, err := txApp.FindCollectionByNameOrId("rankings_extended")
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBCloseRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
			return fmt.Errorf("ExecuteDBCloseRound: failed to find rankings_extended table: %v", err)
		}
		var player []*core.Record
		if Data.RoundKind == roundKindSwiss {
			//take the last player in ranking
			player, err = txApp.FindRecordsByFilter(
				collectionRR,
				"id_tournament = {:tournamentID} && currentRoundIndex = {:roundIndex} && id_round = {:roundId}",
				"-points,-T1,-T2,-T3",
				1,
				0,
				dbx.Params{
					"tournamentID": Data.TournamentID,
					"roundIndex":   Data.RoundIndex,
					"roundId":      Data.RoundId,
				},
			)
		} else {
			player, err = txApp.FindRecordsByFilter(
				collectionRR,
				"id_tournament = {:tournamentID} && currentRoundIndex = {:roundIndex} && id_round = {:roundId} && lastWon = true",
				"-points,-T1,-T2,-T3",
				-1,
				0,
				dbx.Params{
					"tournamentID": Data.TournamentID,
					"roundIndex":   Data.RoundIndex,
					"roundId":      Data.RoundId,
				},
			)
		}
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBCloseRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
			return fmt.Errorf("ExecuteDBCloseRound: failed to find the winners in rankings_extended: %v", err)
		}

		//update the tournament winners
		//update the tournament state
		tournaments, err := txApp.FindCollectionByNameOrId("tournaments")
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBCloseRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
			return fmt.Errorf("ExecuteDBCloseRound: failed to find tournaments table: %v", err)
		}
		tournamentRecord, err := txApp.FindRecordById(tournaments, Data.TournamentID)
		if err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBCloseRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
			return fmt.Errorf("ExecuteDBCloseRound: failed to find the tournament record: %v", err)
		}
		winnersIds := make([]string, 0)
		for _, p := range player {
			winnersIds = append(winnersIds, strings.Trim(p.GetString("id_user"), "\""))
		}
		tournamentRecord.Set("id_winner", winnersIds)
		tournamentRecord.Set("state", "close")
		if err := txApp.Save(tournamentRecord); err != nil {
			app.Logger().Error(fmt.Sprintf("ExecuteDBCloseRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
			return fmt.Errorf("ExecuteDBCloseRound: failed to update the tournament record: %v", err)
		}
		return nil
	})
	if err != nil {
		app.Logger().Error(fmt.Sprintf("ExecuteDBCloseRound ERROR tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
		return fmt.Errorf("ExecuteDBCloseRound: failed to transaction: %v", err)
	}

	app.Logger().Debug(fmt.Sprintf("ExecuteDBCloseRound END tournamentId=%s roundIndex=%d", Data.TournamentID, Data.RoundIndex))
	return nil
}
