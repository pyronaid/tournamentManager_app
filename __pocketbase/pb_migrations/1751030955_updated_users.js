/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id = id ||\n@collection.enrollments.id_user = id && (\n  @collection.enrollments.id_tournament.id_owner = @request.auth.id ||\n  @collection.enrollments.id_tournament ?~ @collection.enrollments.id_tournament\n) && @collection.enrollments.id_user ?~ @request.auth.id",
    "viewRule": "@request.auth.id = id ||\n@collection.enrollments.id_user = id && (\n  @collection.enrollments.id_tournament.id_owner = @request.auth.id ||\n  @collection.enrollments.id_tournament ?~ @collection.enrollments.id_tournament\n) && @collection.enrollments.id_user ?~ @request.auth.id"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  // update collection data
  unmarshal({
    "listRule": "id = @request.auth.id || (\n\t@collection.enrollments.id_user = id && \n\t\t(@collection.enrollments.id_tournament.id_owner = @request.auth.id\n\t\t|| @collection.enrollments.id_user = @request.auth.id)\n\t)",
    "viewRule": "id = @request.auth.id || (\n\t@collection.enrollments.id_user = id && \n\t\t(@collection.enrollments.id_tournament.id_owner = @request.auth.id\n\t\t|| @collection.enrollments.id_user = @request.auth.id)\n\t)"
  }, collection)

  return app.save(collection)
})
