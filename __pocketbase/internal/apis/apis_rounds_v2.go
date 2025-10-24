package apis

import (
	"crypto/rand"
	"database/sql"
	"errors"
	"fmt"
	"math/big"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
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
	TB1    float64
	TB2    float64
	TB3    float64
}

type PairingData struct {
	UserIdPlayerA string
	UserIdPlayerB string
	IsBye         bool
	TableIndex    int
	UserIdWinner  string
}

// Retrieve the list of eligible users that should be paired
// for each i have also the info of points, t1, t2 and t3
// The list is ordered by points desc, tb1 desc, tb2 desc, tb3 desc, userId asc
func GetEligiblePlayersForPairing(app *pocketbase.PocketBase, tournamentId string, roundIndex int, roundSize int) ([]PlayerData, map[string]map[string]bool, map[string]bool, error) {
	var playersToPair []PlayerData
	var prevOpponentsMap = map[string]map[string]bool{}
	var hadByeMap = map[string]bool{}

	add := func(a, b string) {
		if prevOpponentsMap[a] == nil {
			prevOpponentsMap[a] = map[string]bool{}
		}
		prevOpponentsMap[a][b] = true
	}

	app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing START tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	if roundIndex < 1 {
		return playersToPair, prevOpponentsMap, hadByeMap, errors.New("GetEligiblePlayersForPairing roundIndex not acceptable")
	}
	app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing VALIDATED INPUTS tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	if roundIndex == 1 {
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing CASE roundIndex=1 tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		// first round, all players with 0 points
		collectionE, err := app.FindCollectionByNameOrId("enrollments")
		if err != nil {
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
				return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing the table enrollments is not populated: %w", err)
			}
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to check enrollments for this tournament: %w", err)
		}
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing Populate PlayerData roundIndex=1 tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		for _, record := range enrollments {
			pairing := PlayerData{
				UserId: record.GetString("id_user"),
				Points: 0,
				TB1:    0.0,
				TB2:    0.0,
				TB3:    0.0,
			}
			playersToPair = append(playersToPair, pairing)
		}
	} else {
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing CASE roundIndex!=1 tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		collectionRR, err := app.FindCollectionByNameOrId("rankings_extended")
		if err != nil {
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to find rankings table: %w", err)
		}
		rankings, err := app.FindRecordsByFilter(
			collectionRR,
			"id_tournament = {:tournamentID} && id_round.roundIndex = {:roundIndex} && dropped = false",
			"-points,-TB1,-TB2,-TB3",
			roundSize,
			0,
			dbx.Params{
				"tournamentID": tournamentId,
				"roundIndex":   roundIndex,
			},
		)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) { // or PocketBase equivalent
				return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing the table rankings is not populated for the selected round: %w", err)
			}
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to check rankings for this tournament: %w", err)
		}
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing Populate PlayerData roundIndex=1 tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		for _, record := range rankings {
			pairing := PlayerData{
				UserId: record.GetString("id_user"),
				Points: record.GetInt("points"),
				TB1:    record.GetFloat("TB1"),
				TB2:    record.GetFloat("TB2"),
				TB3:    record.GetFloat("TB3"),
			}
			playersToPair = append(playersToPair, pairing)
		}

		//Populating history and bye map
		collectionP, err := app.FindCollectionByNameOrId("pairings")
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
				return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing the table pairings is not populated for the selected tournament: %w", err)
			}
			return playersToPair, prevOpponentsMap, hadByeMap, fmt.Errorf("GetEligiblePlayersForPairing failed to check pairings for this tournament: %w", err)
		}
		app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing Populate prevOpponentsMap & hadByeMap roundIndex=1 tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
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
	app.Logger().Debug(fmt.Sprintf("GetEligiblePlayersForPairing END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	return playersToPair, prevOpponentsMap, hadByeMap, nil
}

// Shuffle a list of PlayerData
// Fisher–Yates with crypto/rand for reproducibility you can inject a RNG
func ShufflePlayersList(app *pocketbase.PocketBase, players []PlayerData, tournamentId string, roundIndex int) error {
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
func CreateByePairingIfNeeded(app *pocketbase.PocketBase, players []PlayerData, hadByeMap map[string]bool, tournamentId string, roundIndex int) (*PairingData, []PlayerData, error) {
	app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded START tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	if len(players)%2 == 0 {
		//even number of players, no bye needed
		app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded No needed because even number of players tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		app.Logger().Debug(fmt.Sprintf("CreateByePairingIfNeeded END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
		return nil, players, nil
	}
	//odd number of players, bye needed
	//var byePlayerIndex = -1
	for i := len(players) - 1; i >= 0; i-- {
		player := players[i]
		if !hadByeMap[player.UserId] {
			byePairing := &PairingData{
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
			return byePairing, players, nil
		}
	}
	return nil, players, errors.New("CreateByePairingIfNeeded no eligible player for bye found - all players already had a bye")
}

// function that given the list of player return an array containing some sub-array
// where every sub-array is a cluster of players with same points
func ClusterPlayersByPoints(app *pocketbase.PocketBase, players []PlayerData, tournamentId string, roundIndex int) ([][]PlayerData, error) {
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
func PairClusterWithRematchHandling(app *pocketbase.PocketBase, cluster []PlayerData, lefthovers []PlayerData, prevOpponentsMap map[string]map[string]bool, tournamentId string, roundIndex int) ([]PairingData, []PlayerData, error) {
	app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling START tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	var pairings []PairingData
	var newLefthovers []PlayerData
	usedInThisCluster := map[string]bool{}
	//first handle lefthovers
	app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling Lefthovers management tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	for _, leftover := range lefthovers {
		found := false
		for i, player := range cluster {
			if prevOpponentsMap[leftover.UserId] != nil && prevOpponentsMap[leftover.UserId][player.UserId] != true && !usedInThisCluster[player.UserId] {
				pairing := PairingData{
					UserIdPlayerA: leftover.UserId,
					UserIdPlayerB: player.UserId,
					IsBye:         false,
					TableIndex:    0, //to be assigned later
					UserIdWinner:  "",
				}
				pairings = append(pairings, pairing)
				usedInThisCluster[player.UserId] = true
				//remove player from cluster
				cluster = append(cluster[:i], cluster[i+1:]...)
				found = true
				break
			}
		}
		//if not found keep in lefthovers for next cluster
		if !found {
			//keep in lefthovers
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
			if prevOpponentsMap[pairing.UserIdPlayerA] != nil && prevOpponentsMap[pairing.UserIdPlayerA][pairing.UserIdPlayerB] == true {
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
					if prevOpponentsMap[pairings[j].UserIdPlayerA] != nil && prevOpponentsMap[pairings[j].UserIdPlayerA][pairings[j].UserIdPlayerB] == true {
						newRematchCreated = true
					}
				} else {
					pairings[rematchIndex].UserIdPlayerB, bottomHalf[j].UserId = bottomHalf[j].UserId, pairings[rematchIndex].UserIdPlayerB
				}
				//check if rematch resolved and no new rematch created
				if prevOpponentsMap[pairings[rematchIndex].UserIdPlayerA] != nil && prevOpponentsMap[pairings[rematchIndex].UserIdPlayerA][pairings[rematchIndex].UserIdPlayerB] == true {
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
					if prevOpponentsMap[pairings[j].UserIdPlayerA] != nil && prevOpponentsMap[pairings[j].UserIdPlayerA][pairings[j].UserIdPlayerB] == true {
						newRematchCreated = true
					}
					//check if rematch resolved and no new rematch created
					if prevOpponentsMap[pairings[rematchIndex].UserIdPlayerA] != nil && prevOpponentsMap[pairings[rematchIndex].UserIdPlayerA][pairings[rematchIndex].UserIdPlayerB] == true {
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
				if len(bottomHalf) > len(topHalf) {
					app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling This cluster has odd number of players - adding last player of bottom half to lefthovers tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
					newLefthovers = append(newLefthovers, bottomHalf[len(bottomHalf)-1])
				}
				app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling Could not resolve rematch between %s and %s - adding to lefthovers tournamentId=%s roundIndex=%d", pairings[rematchIndex].UserIdPlayerA, pairings[rematchIndex].UserIdPlayerB, tournamentId, roundIndex))
				//remove pairing
				pairings = append(pairings[:rematchIndex], pairings[rematchIndex+1:]...)
			}
		}
	}

	app.Logger().Debug(fmt.Sprintf("PairClusterWithRematchHandling END tournamentId=%s roundIndex=%d", tournamentId, roundIndex))
	return pairings, newLefthovers, nil
}
