/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2560115994")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && \n@collection.enrollments.id_tournament = id && \n@collection.enrollments.id_user = @request.auth.id",
    "viewRule": "@request.auth.id != \"\" && \n@collection.enrollments.id_tournament = id && \n@collection.enrollments.id_user = @request.auth.id"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2560115994")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\""
  }, collection)

  return app.save(collection)
})
