/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user\n  \nFROM \n    ENROLLMENTS e;"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "hidden": false,
    "id": "json416626702",
    "maxSize": 1,
    "name": "id_tournament",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "json112446027",
    "maxSize": 1,
    "name": "id_user",
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
    "viewQuery": "SELECT \n  e.id\n  \nFROM \n    ENROLLMENTS e;"
  }, collection)

  // remove field
  collection.fields.removeById("json416626702")

  // remove field
  collection.fields.removeById("json112446027")

  return app.save(collection)
})
