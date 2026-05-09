/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && (\n    id_user = @request.auth.id || \n    id_owner = @request.auth.id ||\n    (@collection.enrollments.id_user ?= @request.auth.id && @collection.enrollments.id_tournament ?= id_tournament)\n)",
    "viewRule": "@request.auth.id != \"\" && (\n    id_user = @request.auth.id || \n    id_owner = @request.auth.id ||\n    (@collection.enrollments.id_user ?= @request.auth.id && @collection.enrollments.id_tournament ?= id_tournament)\n)"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_SWni")

  // remove field
  collection.fields.removeById("_clone_PaKD")

  // remove field
  collection.fields.removeById("_clone_Nvgk")

  // remove field
  collection.fields.removeById("_clone_iQnP")

  // add field
  collection.fields.addAt(6, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_bvWQ",
    "max": 255,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_USpz",
    "max": 0,
    "min": 0,
    "name": "surname",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_Hj4G",
    "max": 0,
    "min": 0,
    "name": "username",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "_clone_4U8M",
    "maxSize": 1,
    "name": "id_owner",
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
    "listRule": null,
    "viewRule": null
  }, collection)

  // add field
  collection.fields.addAt(6, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_SWni",
    "max": 255,
    "min": 0,
    "name": "name",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_PaKD",
    "max": 0,
    "min": 0,
    "name": "surname",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_Nvgk",
    "max": 0,
    "min": 0,
    "name": "username",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "_clone_iQnP",
    "maxSize": 1,
    "name": "id_owner",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // remove field
  collection.fields.removeById("_clone_bvWQ")

  // remove field
  collection.fields.removeById("_clone_USpz")

  // remove field
  collection.fields.removeById("_clone_Hj4G")

  // remove field
  collection.fields.removeById("_clone_4U8M")

  return app.save(collection)
})
