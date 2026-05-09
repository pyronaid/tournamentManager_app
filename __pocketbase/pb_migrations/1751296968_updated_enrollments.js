/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1009377862")

  // update collection data
  unmarshal({
    "listRule": "id_user = @request.auth.id || id_tournament.id_owner = @request.auth.id",
    "viewRule": "id_user = @request.auth.id || id_tournament.id_owner = @request.auth.id"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1009377862")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && (\n    id_user = @request.auth.id || \n    id_tournament.id_owner = @request.auth.id ||\n    (@collection.enrollments.id_user ?= @request.auth.id && @collection.enrollments.id_tournament ?= id_tournament)\n)",
    "viewRule": "@request.auth.id != \"\" && (\n    id_user = @request.auth.id || \n    id_tournament.id_owner = @request.auth.id ||\n    (@collection.enrollments.id_user ?= @request.auth.id && @collection.enrollments.id_tournament ?= id_tournament)\n)"
  }, collection)

  return app.save(collection)
})
