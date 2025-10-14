const functions = require("firebase-functions");

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
  await firestore.collection("users").doc(user.uid).delete();
});

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
const {SecretManagerServiceClient} = require("@google-cloud/secret-manager");
const client = new SecretManagerServiceClient();

exports.getSecretApiKey = functions.https.onCall(async (data, context) => {
  try {
    const [version] = await client.accessSecretVersion({
      name: "projects/427466387534/secrets/secret-pak/versions/latest",
    });

    const payload = version.payload.data.toString("utf8");
    return {apiKey: payload};
  } catch (error) {
    console.error("Failed to access secret:", error);
    throw new functions.https.HttpsError("internal", "Failed to retrieve sec");
  }
});
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////