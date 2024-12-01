"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.helloWorld = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
exports.helloWorld = (0, https_1.onRequest)((request, response) => {
    // debugger;
    logger.info("Hello logs!", { structuredData: true });
    const name = request.params[0];
    const items = { lamp: "this is a lamp", chair: "this is a chair" };
    const message = items[name];
    response.send("<h1>" + message + "</h1>");
});
//# sourceMappingURL=helloWorld.js.map