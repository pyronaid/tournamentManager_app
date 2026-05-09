/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user,\n  e.listKind\nFROM \n    ENROLLMENTS e;"
  }, collection)

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "json3340670512",
    "maxSize": 1,
    "name": "listKind",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user\n  \nFROM \n    ENROLLMENTS e;"
  }, collection)

  // remove field
  collection.fields.removeById("json3340670512")

  return app.save(collection)
})
