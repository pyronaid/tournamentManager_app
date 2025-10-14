import * as admin from "firebase-admin";
import {FieldValue} from "firebase-admin/firestore";

import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";


// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const createTopCutRound = onCall(
  async (request: CallableRequest<any>) => {
    try {
      const data = request.data;
      const context = request.auth;

      // Validate authentication
      if (!context) {
        throw new HttpsError("unauthenticated", "User must be authenticated");
      }

      // //////////////////////////////////////////////////////
      // Retrieve parameters
      // //////////////////////////////////////////////////////
      const index: number = data.index;
      const tournamentId: string = data.tournamentId;
      const creatorId: string = data.creatorId;
      const sizeTopCut: number = data.sizeTopCut;

      // //////////////////////////////////////////////////////
      // Validate inputs
      // //////////////////////////////////////////////////////
      if (typeof index !== "number" || !Number.isInteger(index) || !Number.isFinite(index)) {
        throw new HttpsError("invalid-argument", "index: Value must be a valid integer");
      }
      if (index < 0) {
        throw new HttpsError("invalid-argument", "index: Value must be a positive integer");
      }
      if (typeof tournamentId !== "string" || tournamentId === null || tournamentId.trim().length === 0) {
        throw new HttpsError("invalid-argument", "tournamentId: Value must be a non-empty string");
      }
      if (index > 0 && (typeof sizeTopCut !== "number" || !Number.isInteger(sizeTopCut) || !Number.isFinite(sizeTopCut))) {
        throw new HttpsError("invalid-argument", "sizeTopCut: Value must be a valid integer");
      }
      if (sizeTopCut <= 0 || (sizeTopCut & (sizeTopCut - 1)) !== 0) {
        throw new HttpsError("invalid-argument", "sizeTopCut: Value must be a power of 2 (2, 4, 8, 16, 32, etc.)");
      }

      const db = admin.firestore();
      const timestamp = FieldValue.serverTimestamp();
      return db.runTransaction(async (transaction) => {
        // //////////////////////////////////////////////////////
        // verify absence of index in subcollection
        // //////////////////////////////////////////////////////
        const checkRankingIndexQuery = db
          .collection(`tournaments/${tournamentId}/rounds`) // Fixed string interpolation
          .where("index", "==", index)
          .limit(1);
        const checkRankingIndexSnapshot = await transaction.get(checkRankingIndexQuery);
        if (!checkRankingIndexSnapshot.empty) {
          throw new HttpsError("already-exists", `Round ${index} already exists`);
        }
        // //////////////////////////////////////////////////////
        // Validate tournament state
        // //////////////////////////////////////////////////////
        const checkTournamentQuery = db.doc(`tournaments/${tournamentId}`);
        const checkTournamentSnapshot = await transaction.get(checkTournamentQuery);
        if (!checkTournamentSnapshot.exists) {
          throw new HttpsError("not-found", `Tournament ${tournamentId} not found`);
        }
        const checkTournamentData = checkTournamentSnapshot.data();
        if (checkTournamentData?.state !== "open") {
          throw new HttpsError("failed-precondition", `Tournament ${tournamentId} is not in an open state`);
        }
        // //////////////////////////////////////////////////////
        // verify all the previous rounds are ended in order to generate the new one
        // //////////////////////////////////////////////////////
        if (index !== 0) {
          const checkRoundStateQuery = db
            .collection(`tournaments/${tournamentId}/rounds`)
            .where("completed", "!=", true)
            .limit(1);
          const checkRoundStateSnapshot = await transaction.get(checkRoundStateQuery);
          if (!checkRoundStateSnapshot.empty) {
            throw new HttpsError("failed-precondition", `Previous Round of tournament ${tournamentId} is not complete`);
          }
        }


        // //////////////////////////////////////////////////////
        // write a new record in rounds table
        // //////////////////////////////////////////////////////
        const roundsCollectionRef = db.collection(`tournaments/${tournamentId}/rounds`);
        const roundsRef = roundsCollectionRef.doc();
        const roundId = roundsRef.id;

        const dataToInsertIntoRound = {
          tournament_uid: tournamentId,
          index: index,
          kind: "top",
          completed: false,
          timestamp: timestamp, // Fixed reference to waitingListInfoData
          creator_uid: creatorId,
        };
        transaction.set(roundsRef, dataToInsertIntoRound, {merge: true});

        let processedDocs: any[] = [];
        if (index === 0) {
          // //////////////////////////////////////////////////////
          // took all the registered players and shuffle them
          // //////////////////////////////////////////////////////
          const registeredListQuery = db
            .collection("registered_list_info")
            .where("tournament_uid", "==", tournamentId);
          const registeredListSnapshot = await transaction.get(registeredListQuery);
          processedDocs = [...registeredListSnapshot.docs];
          for (let i = processedDocs.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [processedDocs[i], processedDocs[j]] = [processedDocs[j], processedDocs[i]];
          }
          // //////////////////////////////////////////////////////
          // verify the closest power of 2 to understand if fake bye objects are needed
          // //////////////////////////////////////////////////////
          const nextPowerOf2 = Math.pow(2, Math.ceil(Math.log2(processedDocs.length)));
          const numByeDocs = nextPowerOf2 - processedDocs.length;
          const maxIndex = processedDocs.length + numByeDocs - 1;
          const byeIndices = new Set<number>();
          while (byeIndices.size < numByeDocs) {
            const randomOddIndex = 1 + 2 * Math.floor(Math.random() * ((maxIndex - 1) / 2));
            if (!byeIndices.has(randomOddIndex) && randomOddIndex < maxIndex) {
              byeIndices.add(randomOddIndex);
            }
          }
          const sortedByeIndices = Array.from(byeIndices).sort((a, b) => a - b);
          sortedByeIndices.forEach((pos, index) => {
            processedDocs.splice(pos - index, 0, {
              tournament_uid: tournamentId,
              user_uid: "0000000000",
              display_name: "BYE",
              timestamp: timestamp,
            });
          });
        } else {
          // //////////////////////////////////////////////////////
          // took info from previous round
          // //////////////////////////////////////////////////////
          const previousRoundInfoQuery = db
            .collection(`tournaments/${tournamentId}/rounds`)
            .where("index", "==", index-1)
            .limit(1);
          const previousRoundInfoSnapshot = await transaction.get(previousRoundInfoQuery);
          if (previousRoundInfoSnapshot.empty) {
            throw new HttpsError("failed-precondition", `Previous Round of tournament ${tournamentId} not found`);
          }
          const previous_kind = previousRoundInfoSnapshot.docs[0].data().kind;
          const previous_id = previousRoundInfoSnapshot.docs[0].data().id;
          if (previous_kind == "swiss") {
            // //////////////////////////////////////////////////////
            // swiss previous round - get the best X from rankings
            // //////////////////////////////////////////////////////
            const previousRoundRankingsQuery = db
              .collection(`tournaments/${tournamentId}/rounds/${previous_id}/rankings`)
              .orderBy("points", "desc")
              .orderBy("tie_break_1", "desc")
              .orderBy("tie_break_2", "desc")
              .orderBy("tie_break_3", "desc")
              .orderBy("user_uid", "asc")
              .limit(sizeTopCut);
            const previousRoundRankingsSnapshot = await transaction.get(previousRoundRankingsQuery);
            const sortedDocs = [...previousRoundRankingsSnapshot.docs];
            processedDocs = [];
            let start = 0;
            let end = sortedDocs.length - 1;
            while (start <= end) {
              processedDocs.push(sortedDocs[start]);
              start++;
              if (start <= end) {
                processedDocs.push(sortedDocs[end]);
                end--;
              }
            }
          } else {
            // //////////////////////////////////////////////////////
            // top cut previous round
            // //////////////////////////////////////////////////////
            const maxPointsQuery = db
              .collection(`tournaments/${tournamentId}/rounds/${previous_id}/rankings`)
              .orderBy("points", "desc")
              .limit(1);
            const maxPointsSnapshot = await transaction.get(maxPointsQuery);
            let maxPoints = 0;
            if (!maxPointsSnapshot.empty) {
              maxPoints = maxPointsSnapshot.docs[0].data().points;
            }

            const previousRoundRankingsQuery = db
              .collection(`tournaments/${tournamentId}/rounds/${previous_id}/rankings`)
              .orderBy("index", "asc")
              .where("points", "==", maxPoints);
            const previousRoundRankingsSnapshot = await transaction.get(previousRoundRankingsQuery);
            processedDocs = [...previousRoundRankingsSnapshot.docs];
          }
        }

        await handleRankingsAndPairingsGeneration(
          db,
          transaction,
          processedDocs,
          tournamentId,
          roundId,
          timestamp
        );
        return {roundId: roundId, message: `Round ${index} created successfully`};
      });
    } catch (error) {
      console.error("Failed to generate round:", error);
      throw new HttpsError("internal", "Failed to generate round", error);
    }
  }
);

// //////////////////////////////////////////////////////
// FUNCTION DECLARATION
// //////////////////////////////////////////////////////
/**
 * Creates pairings and rankings for players in a tournament round
 *
 * @param {FirebaseFirestore.Firestore} db - The Firestore database instance.
 * @param {FirebaseFirestore.Transaction} transaction - Firestore transaction
 * @param {FirebaseFirestore.QueryDocumentSnapshot[]} docsList - Array of player documents (already shuffled).
 * @param {string} tournamentId - ID of the tournament
 * @param {string} roundId - ID of the round
 * @param {FirebaseFirestore.FieldValue} timestamp - Server timestamp for consistency across records
 * @return {Promise<void>} A promise that resolves when the promotion operation is complete.
 */
async function handleRankingsAndPairingsGeneration(
  db: FirebaseFirestore.Firestore,
  transaction: FirebaseFirestore.Transaction,
  docsList: any[],
  tournamentId: string,
  roundId: string,
  timestamp: FirebaseFirestore.FieldValue
) {
  let table_index = 1;
  let ranking_index = 1;

  // //////////////////////////////////////////////////////
  // Create a sub collection ranking record for each of them and a sub collection pairing for the couple
  // //////////////////////////////////////////////////////
  for (let i = 0; i < docsList.length; i += 2) {
    const player1Name = docsList[i].data().display_name;
    const player1Uid = docsList[i].data().user_uid;
    const player2Name = docsList[i + 1].data().display_name; // : "BYE";
    const player2Uid = docsList[i + 1].data().user_uid; // : "0000000000";

    // //////////////////////////////////////////////////////
    // first save the rankings table
    // //////////////////////////////////////////////////////
    const rankingSubCollectionRef = db.collection(`tournaments/${tournamentId}/rounds/${roundId}/rankings`);

    // Player 1 ranking
    const rankingRef1 = rankingSubCollectionRef.doc();
    const dataToInsertIntoRanking1 = {
      index: ranking_index++,
      tournament_uid: tournamentId,
      round_uid: roundId,
      user_uid: player1Uid,
      display_name: player1Name,
      points: 0,
      tie_break_1: 0.0,
      tie_break_2: 0.0,
      tie_break_3: 0.0,
      faced_players_history: [],
      timestamp: timestamp,
    };
    transaction.set(rankingRef1, dataToInsertIntoRanking1, {merge: true});

    // Player 2 ranking
    const rankingRef2 = rankingSubCollectionRef.doc();
    const dataToInsertIntoRanking2 = {
      index: ranking_index++,
      tournament_uid: tournamentId,
      round_uid: roundId,
      user_uid: player2Uid,
      display_name: player2Name,
      points: 0,
      tie_break_1: 0.0,
      tie_break_2: 0.0,
      tie_break_3: 0.0,
      faced_players_history: [],
      timestamp: timestamp,
    };
    transaction.set(rankingRef2, dataToInsertIntoRanking2, {merge: true});


    // //////////////////////////////////////////////////////
    // second save the pairing table
    // //////////////////////////////////////////////////////
    const player2IsABye = (player2Name == "BYE" && player2Uid == "0000000000");
    const pairingSubCollectionRef = db.collection(`tournaments/${tournamentId}/rounds/${roundId}/pairings`);
    const pairingRef = pairingSubCollectionRef.doc();
    const dataToInsertIntoPairing = {
      tournament_uid: tournamentId,
      round_uid: roundId,
      user_uid_A: player1Uid,
      display_name_A: player1Name,
      user_uid_B: player2Uid,
      display_name_B: player2Name,
      table_index: table_index++,
      bye_win: player2IsABye,
      winner_uid: player2IsABye ? player1Uid : null,
      timestamp: timestamp,
    };
    transaction.set(pairingRef, dataToInsertIntoPairing, {merge: true});
  }
}
