import * as admin from "firebase-admin";
import {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
} from "firebase-functions/v2/firestore";
import {HttpsError} from "firebase-functions/v2/https";

admin.initializeApp();

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
        const updates = snapshot1.docs.map((doc) =>
          doc.ref.update({
            display_name: updatedDocument.display_name,
          })
        );
        // Execute all updates concurrently
        await Promise.all(updates);
        console.log(`Success synced waitingUsers for userId: ${userId}`);
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
        const updates = snapshot2.docs.map((doc) =>
          doc.ref.update({
            display_name: updatedDocument.display_name,
          })
        );
        // Execute all updates concurrently
        await Promise.all(updates);
        console.log(`Success synced preregisteredUsers for userId: ${userId}`);
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
        const updates = snapshot3.docs.map((doc) =>
          doc.ref.update({
            display_name: updatedDocument.display_name,
          })
        );
        // Execute all updates concurrently
        await Promise.all(updates);
        console.log(`Success synced registeredUsers for userId: ${userId}`);
      }

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
      await db.runTransaction(async (transaction) => {
        const docRef = db.collection("tournaments").doc(data.tournament_uid);
        const snapshot1 = await transaction.get(docRef);
        if (!snapshot1.exists) {
          console.log(
            `No tournament found for tournamentUid: ${data.tournament_uid}`
          );
        } else {
          const currentCount = snapshot1.data()?.waiting_list_counter ?? 0;
          transaction.update(docRef, {
            waiting_list_counter: currentCount + 1,
          });

          console.log(
            `Success incr waiting for tournament: ${data.tournament_uid}`
          );
        }
      });
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
      await db.runTransaction(async (transaction) => {
        const docRef = db.collection("tournaments").doc(data.tournament_uid);
        const snapshot1 = await transaction.get(docRef);
        if (!snapshot1.exists) {
          console.log(
            `No tournament found for tournamentUid: ${data.tournament_uid}`
          );
        } else {
          await db.runTransaction(async (transaction) => {
            const currentCount =
              snapshot1.data()?.pre_registered_list_counter ?? 0;
            transaction.update(docRef, {
              pre_registered_list_counter: currentCount + 1,
            });
          });
          console.log(
            `Success inc preregistered for tournament: ${data.tournament_uid}`
          );
        }
      });
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
      await db.runTransaction(async (transaction) => {
        const docRef = db.collection("tournaments").doc(data.tournament_uid);
        const snapshot1 = await transaction.get(docRef);
        if (!snapshot1.exists) {
          console.log(
            `No tournament found for tournamentUid: ${data.tournament_uid}`
          );
        } else {
          const currentCount = snapshot1.data()?.registered_list_counter ?? 0;
          transaction.update(docRef, {
            registered_list_counter: currentCount + 1,
          });

          console.log(
            `Success incr registered for tournament: ${data.tournament_uid}`
          );
        }
      });
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
      await db.runTransaction(async (transaction) => {
        const docRef = db.collection("tournaments").doc(data.tournament_uid);
        const snapshot1 = await transaction.get(docRef);
        if (!snapshot1.exists) {
          console.log(
            `No tournament found for tournamentUid: ${data.tournament_uid}`
          );
        } else {
          const currentCount = snapshot1.data()?.waiting_list_counter ?? 0;
          transaction.update(docRef, {
            waiting_list_counter: currentCount - 1,
          });

          console.log(
            `Success decr waiting for tournament: ${data.tournament_uid}`
          );
        }
      });
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
      await db.runTransaction(async (transaction) => {
        const docRef = db.collection("tournaments").doc(data.tournament_uid);
        const snapshot1 = await transaction.get(docRef);
        if (!snapshot1.exists) {
          console.log(
            `No tournament found for tournamentUid: ${data.tournament_uid}`
          );
        } else {
          const currentCount =
            snapshot1.data()?.pre_registered_list_counter ?? 0;
          transaction.update(docRef, {
            pre_registered_list_counter: currentCount - 1,
          });
          console.log(
            `Success decr preregistered for tournament: ${data.tournament_uid}`
          );
        }
      });
      return null;
    } catch (error) {
      console.error(
        `Error decr preregistered for tournamentId: ${data.tournament_uid}`,
        error
      );
      throw new HttpsError("internal", "Error decr preregistered counter");
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
      await db.runTransaction(async (transaction) => {
        const docRef = db.collection("tournaments").doc(data.tournament_uid);
        const snapshot1 = await transaction.get(docRef);
        if (!snapshot1.exists) {
          console.log(
            `No tournament found for tournamentUid: ${data.tournament_uid}`
          );
        } else {
          const currentCount = snapshot1.data()?.registered_list_counter ?? 0;
          transaction.update(docRef, {
            registered_list_counter: currentCount - 1,
          });
          console.log(
            `Success decr registered for tournament: ${data.tournament_uid}`
          );
        }
      });
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
