import * as admin from "firebase-admin";
import {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
} from "firebase-functions/v2/firestore";
import {HttpsError} from "firebase-functions/v2/https";

// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const userUpdatedTrigger = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    // debugger;
    const oldDocument = event.data?.before.data();
    const updatedDocument = event.data?.after.data();
    const userId = event.params?.userId;

    // to remove
    console.log(oldDocument);
    console.log(updatedDocument);
    console.log(userId);

    if (
      !updatedDocument ||
      oldDocument?.display_name == updatedDocument.display_name
    ) {
      console.error(
        "No new data found during user update or" +
          "no need to cascade any update."
      );
      return null;
    }

    const db = admin.firestore();
    const batch = db.batch();

    try {
      // UPDATE THE TABLE WAITING
      const snapshot1 = await db
        .collection("waiting_list_info")
        .where("user_uid", "==", userId)
        .get();
      if (snapshot1.empty) {
        console.log(`No waitingUsers found for userId: ${userId}`);
      } else {
        // Update each matching document with the new user details
        snapshot1.docs.forEach((doc) => {
          batch.update(doc.ref, {
            display_name: updatedDocument.display_name,
          });
        });
      }

      // UPDATE THE TABLE PREREGISTERED
      const snapshot2 = await db
        .collection("preregistered_list_info")
        .where("user_uid", "==", userId)
        .get();
      if (snapshot2.empty) {
        console.log(`No preregisteredUsers found for userId: ${userId}`);
      } else {
        // Update each matching document with the new user details
        snapshot2.docs.forEach((doc) => {
          batch.update(doc.ref, {
            display_name: updatedDocument.display_name,
          });
        });
      }

      // UPDATE THE TABLE REGISTERED
      const snapshot3 = await db
        .collection("registered_list_info")
        .where("user_uid", "==", userId)
        .get();
      if (snapshot3.empty) {
        console.log(`No registeredUsers found for userId: ${userId}`);
      } else {
        // Update each matching document with the new user details
        snapshot3.docs.forEach((doc) => {
          batch.update(doc.ref, {
            display_name: updatedDocument.display_name,
          });
        });
      }

      await batch.commit();
      console.log(`Success synced usersList for userId: ${userId}`);

      return null;
    } catch (error) {
      console.error(`Error syncing user details for userId: ${userId}`, error);
      throw new HttpsError("internal", "Error syncing user details");
    }
  }
);

// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const updateCounterWaitingIncr = onDocumentCreated(
  "waiting_list_info/{waitingInfoId}",
  async (event) => {
    // debugger;
    const snapshot = event.data;
    const waitingInfoId = event.params?.waitingInfoId;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }
    const data = snapshot.data();

    // to remove
    console.log(data);
    const db = admin.firestore();
    try {
      const docRef = db.collection("tournaments").doc(data.tournament_uid);
      await docRef.set({
        waiting_list_counter: admin.firestore.FieldValue.increment(1),
      }, {merge: true});
      return null;
    } catch (error) {
      console.error(
        `Error incr waiting for tournamentId: ${data.tournament_uid}`,
        error
      );
      throw new HttpsError("internal", "Error incr waiting counter");
    }
  }
);

// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const updateCounterPreregisteredIncr = onDocumentCreated(
  "preregistered_list_info/{preregisteredInfoId}",
  async (event) => {
    // debugger;
    const snapshot = event.data;
    const preregisteredInfoId = event.params?.preregisteredInfoId;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }
    const data = snapshot.data();

    // to remove
    console.log(data);
    const db = admin.firestore();
    try {
      const docRef = db.collection("tournaments").doc(data.tournament_uid);
      await docRef.set({
        pre_registered_list_counter: admin.firestore.FieldValue.increment(1),
      }, {merge: true});
      return null;
    } catch (error) {
      console.error(
        `Error incr preregistered for tournamentId: ${data.tournament_uid}`,
        error
      );
      throw new HttpsError("internal", "Error incr preregistered counter");
    }
  }
);

// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const updateCounterRegisteredIncr = onDocumentCreated(
  "registered_list_info/{registeredInfoId}",
  async (event) => {
    // debugger;
    const snapshot = event.data;
    const registeredInfoId = event.params?.registeredInfoId;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }
    const data = snapshot.data();

    // to remove
    console.log(data);
    const db = admin.firestore();
    try {
      const docRef = db.collection("tournaments").doc(data.tournament_uid);
      await docRef.set({
        registered_list_counter: admin.firestore.FieldValue.increment(1),
      }, {merge: true});
      return null;
    } catch (error) {
      console.error(
        `Error incr registered for tournamentId: ${data.tournament_uid}`,
        error
      );
      throw new HttpsError("internal", "Error incr registered counter");
    }
  }
);

// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const updateCounterWaitingDecr = onDocumentDeleted(
  "waiting_list_info/{waitingInfoId}",
  async (event) => {
    // debugger;
    const snapshot = event.data;
    const waitingInfoId = event.params?.waitingInfoId;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }
    const data = snapshot.data();

    // to remove
    console.log(data);
    const db = admin.firestore();
    try {
      const docRef = db.collection("tournaments").doc(data.tournament_uid);
      await docRef.set({
        waiting_list_counter: admin.firestore.FieldValue.increment(-1),
      }, {merge: true});
      return null;
    } catch (error) {
      console.error(
        `Error decr waiting for tournamentId: ${data.tournament_uid}`,
        error
      );
      throw new HttpsError("internal", "Error decr waiting counter");
    }
  }
);

// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const updateCounterPreregisteredDecr = onDocumentDeleted(
  "preregistered_list_info/{preregisteredInfoId}",
  async (event) => {
    // debugger;
    const snapshot = event.data;
    const preregisteredInfoId = event.params?.preregisteredInfoId;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }
    const data = snapshot.data();

    // to remove
    console.log(data);
    const db = admin.firestore();
    try {
      db.runTransaction(async (transaction) => {
        const tournamentCollectionRef = db.collection("tournaments");
        const tournamentRef = tournamentCollectionRef.doc(data.tournament_uid);
        const tournamentSnap = await transaction.get(tournamentRef);
        const tournamentData = tournamentSnap.data()!;

        if (!tournamentSnap.exists) {
          console.log(`No tournament found for tournamentUid: ${data.tournament_uid}`);
          throw new HttpsError("not-found", `Tournament not found:  ${data.tournament_uid}`);
        }

        const {
          capacity = 0,
          registered_list_counter = 0,
          pre_registered_list_counter = 0,
          waiting_list_counter = 0,
          waiting_list_en = false,
        } = tournamentData;
        const shouldMoveFromWaitingList =
          waiting_list_en &&
          waiting_list_counter > 0 &&
          capacity > 0 &&
          (registered_list_counter + pre_registered_list_counter - 1) < capacity;
        if (shouldMoveFromWaitingList) {
          await handleWaitingListPromotion(
            db,
            transaction,
            data.tournament_uid,
            1
          );
        }
      });

      const docRef = db.collection("tournaments").doc(data.tournament_uid);
      await docRef.set({
        pre_registered_list_counter: admin.firestore.FieldValue.increment(-1),
      }, {merge: true});
      return null;
    } catch (error) {
      console.error(
        `Error incr preregistered for tournamentId: ${data.tournament_uid}`,
        error
      );
      throw new HttpsError("internal", "Error incr preregistered counter");
    }
  }
);

// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const updateCounterRegisteredDecr = onDocumentDeleted(
  "registered_list_info/{registeredInfoId}",
  async (event) => {
    // debugger;
    const snapshot = event.data;
    const registeredInfoId = event.params?.registeredInfoId;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }
    const data = snapshot.data();

    // to remove
    console.log(data);
    const db = admin.firestore();
    try {
      const docRef = db.collection("tournaments").doc(data.tournament_uid);
      await docRef.set({
        registered_list_counter: admin.firestore.FieldValue.increment(-1),
      }, {merge: true});
      return null;
    } catch (error) {
      console.error(
        `Error decr registered for tournamentId: ${data.tournament_uid}`,
        error
      );
      throw new HttpsError("internal", "Error decr registered counter");
    }
  }
);

// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
// //////////////////////////////////////////////////////
export const tournamentUpdatedTrigger = onDocumentUpdated(
  "tournaments/{tournamentId}",
  async (event) => {
    // debugger;
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }

    // Validate input
    const oldDocument = event.data?.before.data();
    const updatedDocument = event.data?.after.data();
    const tournamentId = event.params?.tournamentId;

    // to remove
    console.log(oldDocument);
    console.log(updatedDocument);
    console.log(tournamentId);

    if (!updatedDocument || !tournamentId) {
      console.error("No updated document found.");
      throw new HttpsError("invalid-argument", "Invalid tournament update");
    }

    const db = admin.firestore();
    try {
      const preregistrationChanged =
        oldDocument?.pre_registration_en !== updatedDocument.pre_registration_en;
      const waitingListChanged =
        oldDocument?.waiting_list_en !== updatedDocument.waiting_list_en;
      const sizeChanged =
        (oldDocument?.capacity ?? 0) < updatedDocument.capacity;

      // Early return if no relevant changes
      if (!preregistrationChanged && !waitingListChanged && !sizeChanged) {
        console.info("No relevant changes detected.");
        return null;
      }
      db.runTransaction(async (transaction) => {
        if (sizeChanged) {
          console.info("Size changed execution");
          const {
            capacity = 0,
            registered_list_counter = 0,
            pre_registered_list_counter = 0,
            waiting_list_counter = 0,
            waiting_list_en = false,
          } = updatedDocument;
          console.info(`waiting_list_en:${waiting_list_en}`);
          console.info(`waiting_list_counter:${waiting_list_counter}`);
          console.info(`capacity:${capacity}`);
          console.info(`registered_list_counter:${registered_list_counter}`);
          console.info(`pre_registered_list_counter:${pre_registered_list_counter}`);
          const shouldMoveFromWaitingList =
            waiting_list_en &&
            waiting_list_counter > 0 &&
            capacity > 0 &&
            (registered_list_counter + pre_registered_list_counter - 1) < capacity;
          if (shouldMoveFromWaitingList) {
            await handleWaitingListPromotion(
              db,
              transaction,
              tournamentId,
              updatedDocument.capacity - (oldDocument?.capacity ?? 0)
            );
          }
        }
        if (waitingListChanged) {
          // Waiting List Management
          console.info("WaitingList enabled execution");
          await handleWaitingListUpdate(db, transaction, tournamentId);
        }
        if (preregistrationChanged) {
          // Waiting List Management
          console.info("Preregistered enabled execution");
          await handlePreregisteredListUpdate(db, transaction, tournamentId);
        }
      });
    } catch (error) {
      console.error(
        `Error incr preregistered for tournamentId: ${tournamentId}`,
        error
      );
      throw new HttpsError("internal", "Error incr preregistered counter");
    }
    return null;
  }
);

// //////////////////////////////////////////////////////
// FUNCTION DECLARATION
// //////////////////////////////////////////////////////
/**
 * Promotes participants from the waiting list to the pre-registered list in a Firestore trans.
 *
 * @param {FirebaseFirestore.Firestore} db - The Firestore database instance.
 * @param {FirebaseFirestore.Transaction} transaction - The Firestore transaction object.
 * @param {string} tournamentId - The unique identifier of the tournament.
 * @param {number} size - The number of participants to promote from the waiting list.
 * @return {Promise<void>} A promise that resolves when the promotion operation is complete.
 */
async function handleWaitingListPromotion(
  db: FirebaseFirestore.Firestore,
  transaction: FirebaseFirestore.Transaction,
  tournamentId: string,
  size: number,
) {
  // Find the first waiting list participant
  const waitingListQuery = db
    .collection("waiting_list_info")
    .where("tournament_uid", "==", tournamentId)
    .orderBy("timestamp", "asc")
    .limit(size);

  const waitingListSnapshot = await transaction.get(waitingListQuery);

  waitingListSnapshot.docs.forEach((doc) => {
    const waitingListInfoData = doc.data();
    const preregisteredListInfoCollectionRef = db.collection("preregistered_list_info");
    const preregisteredListInfoRef = preregisteredListInfoCollectionRef.doc();

    const dataToInsertIntoPreregistered = {
      tournament_uid: waitingListInfoData.tournament_uid,
      user_uid: waitingListInfoData.user_uid,
      display_name: waitingListInfoData.display_name,
      timestamp: waitingListInfoData.timestamp,
    };

    transaction.set(preregisteredListInfoRef, dataToInsertIntoPreregistered, {merge: true});
    transaction.delete(doc.ref);
  });
}

/**
 * Removes all participants from the waiting list in a Firestore transaction.
 *
 * @param {FirebaseFirestore.Firestore} db - The Firestore database instance.
 * @param {FirebaseFirestore.Transaction} transaction - The Firestore transaction object.
 * @param {string} tournamentId - The identifier of tournament whose waiting list needs be cleared.
  * @return {Promise<void>} A promise resolves when the waiting list removal operation is complete.
 */
async function handleWaitingListUpdate(
  db: FirebaseFirestore.Firestore,
  transaction: FirebaseFirestore.Transaction,
  tournamentId: string,
) {
  // Find the first waiting list participant
  const waitingListQuery = db
    .collection("waiting_list_info")
    .where("tournament_uid", "==", tournamentId);

  const waitingListSnapshot = await transaction.get(waitingListQuery);

  waitingListSnapshot.docs.forEach((doc) => {
    transaction.delete(doc.ref);
  });
}

/**
 * Removes all participants from the waiting list in a Firestore transaction.
 *
 * @param {FirebaseFirestore.Firestore} db - The Firestore database instance.
 * @param {FirebaseFirestore.Transaction} transaction - The Firestore transaction object.
 * @param {string} tournamentId - The identifier of tournament whose waiting list needs be cleared.
 * @return {Promise<void>} A promise resolves when the waiting list removal operation is complete.
 */
async function handlePreregisteredListUpdate(
  db: FirebaseFirestore.Firestore,
  transaction: FirebaseFirestore.Transaction,
  tournamentId: string,
) {
  // Find the first waiting list participant
  const preregisteredListQuery = db
    .collection("preregistered_list_info")
    .where("tournament_uid", "==", tournamentId);

  const preregisteredListSnapshot = await transaction.get(preregisteredListQuery);

  preregisteredListSnapshot.docs.forEach((doc) => {
    transaction.delete(doc.ref);
  });
}
