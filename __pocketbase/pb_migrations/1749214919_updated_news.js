/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_987692768")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX `idx_cICPMdMtqI` ON `news` (`id_tournament`)"
    ]
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_987692768")

  // update collection data
  unmarshal({
    "indexes": []
  }, collection)

  return app.save(collection)
})
