/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_845636082")

  // add field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "file1216345841",
    "maxSelect": 1,
    "maxSize": 0,
    "mimeTypes": [],
    "name": "profilePicture",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": [],
    "type": "file"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_845636082")

  // remove field
  collection.fields.removeById("file1216345841")

  return app.save(collection)
})
