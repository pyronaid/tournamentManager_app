/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update field
  collection.fields.addAt(8, new Field({
    "hidden": false,
    "id": "bool3071060472",
    "name": "preRegistrationEn",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // update field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "bool1231498413",
    "name": "waitingListEn",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_340646327")

  // update field
  collection.fields.addAt(8, new Field({
    "hidden": false,
    "id": "bool3071060472",
    "name": "pre_registration_en",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // update field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "bool1231498413",
    "name": "waiting_list_en",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
})
