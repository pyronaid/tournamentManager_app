"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getApiKeyFromSecret = void 0;
const https_1 = require("firebase-functions/v2/https");
const v2_1 = require("firebase-functions/v2");
(0, v2_1.setGlobalOptions)({
    region: "us-central1",
    memory: "128MiB",
    timeoutSeconds: 10,
    minInstances: 1,
    maxInstances: 5,
    cpu: 1,
    secrets: ["SECRET_PAK"],
});
exports.getApiKeyFromSecret = (0, https_1.onCall)(async (request) => {
    try {
        if (!process.env.SECRET_PAK) {
            throw new https_1.HttpsError("internal", "Secret not found");
        }
        return { apiKey: process.env.SECRET_PAK };
    }
    catch (error) {
        console.error("Failed to access secret:", error);
        throw new https_1.HttpsError("internal", "Failed to retrieve sec");
    }
});
//# sourceMappingURL=getApiKeyFromSecret.js.map