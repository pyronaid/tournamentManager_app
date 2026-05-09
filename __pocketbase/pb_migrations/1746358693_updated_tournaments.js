/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "select590033292",
    "maxSelect": 1,
    "name": "game",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "ygoAdv",
      "ygoRetro",
      "lorcana",
      "onepiece",
      "altered",
      "magic",
      "unknown"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "select590033292",
    "maxSelect": 1,
    "name": "game",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "ygoAdv",
      "ygoRetro",
      "lorcana",
      "onepiece",
      "altered",
      "magic",
      "unknown"
    ]
  }))

  return app.save(collection)
})
