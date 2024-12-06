"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateCounterRegisteredDecr = exports.updateCounterRegisteredIncr = exports.updateCounterPreregisteredDecr = exports.updateCounterPreregisteredIncr = exports.updateCounterWaitingDecr = exports.updateCounterWaitingIncr = exports.userUpdatedTrigger = exports.getAlgoliaApiKeyFromSecret = exports.getApiKeyFromSecret = exports.helloWorld = void 0;
const v2_1 = require("firebase-functions/v2");
(0, v2_1.setGlobalOptions)({
    region: "us-central1",
    memory: "128MiB",
    timeoutSeconds: 10,
    minInstances: 1,
    maxInstances: 5,
    cpu: 1, // #CPU
});
var helloWorld_1 = require("./helloWorld");
Object.defineProperty(exports, "helloWorld", { enumerable: true, get: function () { return helloWorld_1.helloWorld; } });
var getApiKeyFromSecret_1 = require("./getApiKeyFromSecret");
Object.defineProperty(exports, "getApiKeyFromSecret", { enumerable: true, get: function () { return getApiKeyFromSecret_1.getApiKeyFromSecret; } });
var getAlgoliaApiKeyFromSecret_1 = require("./getAlgoliaApiKeyFromSecret");
Object.defineProperty(exports, "getAlgoliaApiKeyFromSecret", { enumerable: true, get: function () { return getAlgoliaApiKeyFromSecret_1.getAlgoliaApiKeyFromSecret; } });
var syncUserDetails_1 = require("./syncUserDetails");
Object.defineProperty(exports, "userUpdatedTrigger", { enumerable: true, get: function () { return syncUserDetails_1.userUpdatedTrigger; } });
Object.defineProperty(exports, "updateCounterWaitingIncr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterWaitingIncr; } });
Object.defineProperty(exports, "updateCounterWaitingDecr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterWaitingDecr; } });
Object.defineProperty(exports, "updateCounterPreregisteredIncr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterPreregisteredIncr; } });
Object.defineProperty(exports, "updateCounterPreregisteredDecr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterPreregisteredDecr; } });
Object.defineProperty(exports, "updateCounterRegisteredIncr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterRegisteredIncr; } });
Object.defineProperty(exports, "updateCounterRegisteredDecr", { enumerable: true, get: function () { return syncUserDetails_1.updateCounterRegisteredDecr; } });
//# sourceMappingURL=index.js.map