import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

type Indexable = { [key: string]: any};

export const helloWorld = onRequest((request, response) => {
  // debugger;
  logger.info("Hello logs!", {structuredData: true});
  const name = request.params[0];
  const items: Indexable = {lamp: "this is a lamp", chair: "this is a chair"};
  const message = items[name];
  response.send("<h1>" + message + "</h1>");
});
