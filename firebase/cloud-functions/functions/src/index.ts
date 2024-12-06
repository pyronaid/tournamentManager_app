import {setGlobalOptions} from "firebase-functions/v2";

setGlobalOptions({
  region: "us-central1", // Default region for all functions
  memory: "128MiB", // Memory allocation
  timeoutSeconds: 10, // Timeout limit
  minInstances: 1, // Min Instances
  maxInstances: 5, // Max Instances
  cpu: 1, // #CPU
});

export {helloWorld} from "./helloWorld";
export {getApiKeyFromSecret} from "./getApiKeyFromSecret";
export {getAlgoliaApiKeyFromSecret} from "./getAlgoliaApiKeyFromSecret";
export {
  userUpdatedTrigger,
  updateCounterWaitingIncr,
  updateCounterWaitingDecr,
  updateCounterPreregisteredIncr,
  updateCounterPreregisteredDecr,
  updateCounterRegisteredIncr,
  updateCounterRegisteredDecr,
} from "./syncUserDetails";
