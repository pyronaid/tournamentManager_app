import {onCall, HttpsError} from "firebase-functions/v2/https";

export const getAlgoliaApiKeyFromSecret = onCall(
  {
    secrets: ["SECRET_AAK"],
  },
  async (request: any) => {
    try {
      if (!process.env.SECRET_AAK) {
        throw new HttpsError("internal", "Secret not found");
      }
      return {apiKey: process.env.SECRET_AAK};
    } catch (error) {
      console.error("Failed to access secret:", error);
      throw new HttpsError("internal", "Failed to retrieve sec");
    }
  });
