/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2282062390")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  id,\n  id_owner\nFROM \n    TOURNAMENTS;"
  }, collection)

  // remove field
  collection.fields.removeById("json1579384326")

  // remove field
  collection.fields.removeById("json3051925876")

  // remove field
  collection.fields.removeById("json2862495610")

  // remove field
  collection.fields.removeById("json590033292")

  // remove field
  collection.fields.removeById("json2744374011")

  // remove field
  collection.fields.removeById("json3309110367")

  // remove field
  collection.fields.removeById("json3071060472")

  // remove field
  collection.fields.removeById("json1231498413")

  // remove field
  collection.fields.removeById("json223244161")

  // remove field
  collection.fields.removeById("json1092145443")

  // remove field
  collection.fields.removeById("json2246143851")

  // remove field
  collection.fields.removeById("json717346275")

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2282062390")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  id,\n  id_owner,\n  name,\n  capacity,\n  date,\n  game,\n  state,\n  image,\n  pre_registration_en,\n  waiting_list_en,\n  address,\n  latitude,\n  longitude,\n  id_winner\nFROM \n    TOURNAMENTS;"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "json1579384326",
    "maxSize": 1,
    "name": "name",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "json3051925876",
    "maxSize": 1,
    "name": "capacity",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "json2862495610",
    "maxSize": 1,
    "name": "date",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "json590033292",
    "maxSize": 1,
    "name": "game",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "json2744374011",
    "maxSize": 1,
    "name": "state",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "json3309110367",
    "maxSize": 1,
    "name": "image",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "hidden": false,
    "id": "json3071060472",
    "maxSize": 1,
    "name": "pre_registration_en",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "json1231498413",
    "maxSize": 1,
    "name": "waiting_list_en",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(10, new Field({
    "hidden": false,
    "id": "json223244161",
    "maxSize": 1,
    "name": "address",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(11, new Field({
    "hidden": false,
    "id": "json1092145443",
    "maxSize": 1,
    "name": "latitude",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(12, new Field({
    "hidden": false,
    "id": "json2246143851",
    "maxSize": 1,
    "name": "longitude",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(13, new Field({
    "hidden": false,
    "id": "json717346275",
    "maxSize": 1,
    "name": "id_winner",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  return app.save(collection)
})
