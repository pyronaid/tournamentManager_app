"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTopCutRound = exports.tournamentUpdatedTrigger = exports.updateCounterRegisteredDecr = exports.updateCounterRegisteredIncr = exports.updateCounterPreregisteredDecr = exports.updateCounterPreregisteredIncr = exports.updateCounterWaitingDecr = exports.updateCounterWaitingIncr = exports.userUpdatedTrigger = exports.getAlgoliaApiWKeyFromSecret = exports.getAlgoliaApiKeyFromSecret = exports.getApiKeyFromSecret = exports.helloWorld = void 0;
const v2_1 = require("firebase-functions/v2");
const admin = require("firebase-admin");
(0, v2_1.setGlobalOptions)({
    region: "us-central1",
    memory: "128MiB",
    timeoutSeconds: 10,
    minInstances: 0,
    maxInstances: 5,
    cpu: 1, // #CPU
});
var helloWorld_1 = require("./helloWorld");
Object.defineProperty(exports, "helloWorld", { enumerable: true, get: function () { return helloWorld_1.helloWorld; } });
var getApiKeyFromSecret_1 = require("./getApiKeyFromSecret");
Object.defineProperty(exports, "getApiKeyFromSecret", { enumerable: true, get: function () { return getApiKeyFromSecret_1.getApiKeyFromSecret; } });
var algoliaApiKeys_1 = require("./algoliaApiKeys");
Object.defineProperty(exports, "getAlgoliaApiKeyFromSecret", { enumerable: true, get: function () { return algoliaApiKeys_1.getAlgoliaApiKeyFromSecret; } });
Object.defineProperty(exports, "getAlgoliaApiWKeyFromSecret", { enumerable: true, get: function () { return algoliaApiKeys_1.getAlgoliaApiWKeyFromSecret; } });
admin.initializeApp();
var syncUserDetails_1 = require("./syncUserDetails");
Object.defineProperty(exports, "userUpdatedTrigger", { enumerable: true, get: function () { return syncUserDetails_1.userUpdatedTrigger; } });
Object.defineProperty(exports, "updateCounterWaitingIncr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterWaitingIncr; } });
Object.defineProperty(exports, "updateCounterWaitingDecr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterWaitingDecr; } });
Object.defineProperty(exports, "updateCounterPreregisteredIncr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterPreregisteredIncr; } });
Object.defineProperty(exports, "updateCounterPreregisteredDecr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterPreregisteredDecr; } });
Object.defineProperty(exports, "updateCounterRegisteredIncr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterRegisteredIncr; } });
Object.defineProperty(exports, "updateCounterRegisteredDecr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterRegisteredDecr; } });
Object.defineProperty(exports, "tournamentUpdatedTrigger", { enumerable: true, get: function () { return syncUserDetails_1.tournamentUpdatedTrigger; } });
var roundsManagements_1 = require("./roundsManagements");
Object.defineProperty(exports, "createTopCutRound", { enumerable: true, get: function () { return roundsManagements_1.createTopCutRound; } });
//# sourceMappingURL=index.js.map