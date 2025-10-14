import {onCall, HttpsError} from "firebase-functions/v2/https";

export const getApiKeyFromSecret = onCall(
  {
    secrets: ["SECRET_PAK"],
  },
  async (request: any) => {
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
