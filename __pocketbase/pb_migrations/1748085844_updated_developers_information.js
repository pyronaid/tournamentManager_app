/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_845636082")

  // remove field
  collection.fields.removeById("text1216345841")

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_845636082")

  // add field
  collection.fields.addAt(4, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1216345841",
    "max": 0,
    "min": 0,
    "name": "profilePicture",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
})
