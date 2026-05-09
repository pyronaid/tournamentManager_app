/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user,\n  e.listKind,\n  e.created,\n  e.updated\nFROM \n    ENROLLMENTS e;"
  }, collection)

  // add field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "json2990389176",
    "maxSize": 1,
    "name": "created",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "json3332085495",
    "maxSize": 1,
    "name": "updated",
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
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user,\n  e.listKind\nFROM \n    ENROLLMENTS e;"
  }, collection)

  // remove field
  collection.fields.removeById("json2990389176")

  // remove field
  collection.fields.removeById("json3332085495")

  return app.save(collection)
})
