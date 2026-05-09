/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1009377862")

  // update collection data
  unmarshal({
    "createRule": "id_user = @request.auth.id || id_tournament.id_owner = @request.auth.id",
    "deleteRule": "id_user = @request.auth.id || id_tournament.id_owner = @request.auth.id",
    "listRule": "id_user = @request.auth.id || id_tournament.id_owner = @request.auth.id",
    "updateRule": "id_user = @request.auth.id || id_tournament.id_owner = @request.auth.id",
    "viewRule": "id_user = @request.auth.id || id_tournament.id_owner = @request.auth.id"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1009377862")

  // update collection data
  unmarshal({
    "createRule": "id_user = @request.auth.id",
    "deleteRule": "id_user = @request.auth.id",
    "listRule": "id_user = @request.auth.id",
    "updateRule": "id_user = @request.auth.id",
    "viewRule": "id_user = @request.auth.id"
  }, collection)

  return app.save(collection)
})
