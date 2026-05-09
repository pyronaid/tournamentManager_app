/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2560115994")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && \n(\n\t@request.auth.id = id_owner || \n\t(@request.auth.id = @collection.enrollments.id_user && id = @collection.enrollments.id_tournament)\n)",
    "viewRule": "@request.auth.id != \"\" && \n(\n\t@request.auth.id = id_owner || \n\t(@request.auth.id = @collection.enrollments.id_user && id = @collection.enrollments.id_tournament)\n)"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2560115994")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && \n((@collection.enrollments.id_tournament = id && \n@collection.enrollments.id_user = @request.auth.id) || id_owner = @request.auth.id) ",
    "viewRule": "@request.auth.id != \"\" && \n((@collection.enrollments.id_tournament = id && \n@collection.enrollments.id_user = @request.auth.id) || id_owner = @request.auth.id) "
  }, collection)

  return app.save(collection)
})
