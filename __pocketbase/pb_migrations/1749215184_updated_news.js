/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_987692768")

  // update collection data
  unmarshal({
    "createRule": "@request.auth.id != \"\" && \n(id_tournament.id_owner = @request.auth.id) ",
    "deleteRule": "@request.auth.id != \"\" && \n(id_tournament.id_owner = @request.auth.id) ",
    "listRule": "@request.auth.id != \"\" && \n((@collection.enrollments.id_tournament = id_tournament && \n@collection.enrollments.id_user = @request.auth.id) || id_tournament.id_owner = @request.auth.id) ",
    "updateRule": "@request.auth.id != \"\" && \n(id_tournament.id_owner = @request.auth.id) ",
    "viewRule": "@request.auth.id != \"\" && \n((@collection.enrollments.id_tournament = id_tournament && \n@collection.enrollments.id_user = @request.auth.id) || id_tournament.id_owner = @request.auth.id) "
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_987692768")

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
