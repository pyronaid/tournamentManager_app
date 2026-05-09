/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update field
  collection.fields.addAt(7, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1579384326",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(8, new Field({
    "hidden": false,
    "id": "select2744374011",
    "maxSelect": 1,
    "name": "state",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "open",
      "ready",
      "ongoing",
      "close",
      "unknown"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update field
  collection.fields.addAt(7, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1579384326",
    "max": 0,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // update field
  collection.fields.addAt(8, new Field({
    "hidden": false,
    "id": "select2744374011",
    "maxSelect": 1,
    "name": "state",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "open",
      "ready",
      "ongoing",
      "close",
      "unknown"
    ]
  }))

  return app.save(collection)
})
