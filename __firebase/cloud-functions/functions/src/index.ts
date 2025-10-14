import {setGlobalOptions} from "firebase-functions/v2";
import * as admin from "firebase-admin";

setGlobalOptions({
  region: "us-central1", // Default region for all functions
  memory: "128MiB", // Memory allocation
  timeoutSeconds: 10, // Timeout limit
  minInstances: 0, // Min Instances
  maxInstances: 5, // Max Instances
  cpu: 1, // #CPU
});

export {helloWorld} from "./helloWorld";
export {getApiKeyFromSecret} from "./getApiKeyFromSecret";
export {
  getAlgoliaApiKeyFromSecret,
  getAlgoliaApiWKeyFromSecret,
} from "./algoliaApiKeys";
admin.initializeApp();
export {
  userUpdatedTrigger,
  updateCounterWaitingIncr,
  updateCounterWaitingDecr,
  updateCounterPreregisteredIncr,
  updateCounterPreregisteredDecr,
  updateCounterRegisteredIncr,
  updateCounterRegisteredDecr,
  tournamentUpdatedTrigger,
} from "./syncUserDetails";
export {
  createTopCutRound,
} from "./roundsManagements";
