/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update collection data
  unmarshal({
    "createRule": "id_owner = @request.auth.id",
    "deleteRule": "id_owner = @request.auth.id",
    "listRule": "id_owner = @request.auth.id",
    "updateRule": "id_owner = @request.auth.id",
    "viewRule": "id_owner = @request.auth.id"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update collection data
  unmarshal({
    "createRule": null,
    "deleteRule": null,
    "listRule": null,
    "updateRule": null,
    "viewRule": null
  }, collection)

  return app.save(collection)
})
