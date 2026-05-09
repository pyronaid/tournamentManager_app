/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX `idx_hYW2SXV4BQ` ON `tournaments` (`id_owner`)"
    ]
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update collection data
  unmarshal({
    "indexes": []
  }, collection)

  return app.save(collection)
})
