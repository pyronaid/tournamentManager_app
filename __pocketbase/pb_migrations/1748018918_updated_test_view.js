/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2282062390")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT id, id_owner FROM TOURNAMENTS;"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2282062390")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  id,\n  id_owner\nFROM \n    TOURNAMENTS;"
  }, collection)

  return app.save(collection)
})
