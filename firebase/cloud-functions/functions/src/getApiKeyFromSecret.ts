import {onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";

setGlobalOptions({
  region: "us-central1", // Default region for all functions
  memory: "128MiB", // Memory allocation
  timeoutSeconds: 10, // Timeout limit
  minInstances: 1, // Min Instances
  maxInstances: 5, // Max Instances
  cpu: 1, // #CPU
  secrets: ["SECRET_PAK"],
});

export const getApiKeyFromSecret = onCall(async (request: any) => {
  try {
    if (!process.env.SECRET_PAK) {
      throw new HttpsError("internal", "Secret not found");
    }
    return {apiKey: process.env.SECRET_PAK};
  } catch (error) {
    console.error("Failed to access secret:", error);
    throw new HttpsError("internal", "Failed to retrieve sec");
  }
});
