"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getApiKeyFromSecret = void 0;
const https_1 = require("firebase-functions/v2/https");
exports.getApiKeyFromSecret = (0, https_1.onCall)({
    secrets: ["SECRET_PAK"],
}, async (request) => {
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