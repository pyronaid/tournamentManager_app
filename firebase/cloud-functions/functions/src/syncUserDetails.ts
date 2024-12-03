import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions/v2";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {HttpsError} from "firebase-functions/v2/https";

setGlobalOptions({
  region: "us-central1", // Default region for all functions
  memory: "128MiB", // Memory allocation
  timeoutSeconds: 10, // Timeout limit
  minInstances: 1, // Min Instances
  maxInstances: 5, // Max Instances
  cpu: 1, // #CPU
  // secrets: ["SECRET_PAK"],
});

admin.initializeApp();

export const userUpdatedTrigger = onDocumentUpdated("users/{userId}",
  async (event) => {
  // debugger;
    const oldDocument = event.data?.before.data();
    const updatedDocument = event.data?.after.data();
    const userId = event.params?.userId;

    // to remove
    console.log(oldDocument);
    console.log(updatedDocument);
    console.log(userId);

    if (!updatedDocument ||
        oldDocument?.display_name == updatedDocument.display_name) {
      console.error("No new data found during user update or" +
          "no need to cascade any update.");
      return null;
    }

    const db = admin.firestore();
    try {
      // UPDATE THE TABLE WAITING
      const snapshot1 = await db.collection("waiting_list_info")
        .where("user_uid", "==", userId).get();
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
      const snapshot2 = await db.collection("preregistered_list_info")
        .where("user_uid", "==", userId).get();
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
      const snapshot3 = await db.collection("registered_list_info")
        .where("user_uid", "==", userId).get();
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
      throw new HttpsError("internal", "Error syncing user details"
      );
    }
  });
