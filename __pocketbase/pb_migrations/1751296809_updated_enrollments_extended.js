/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user,\n  e.listKind,\n  e.created,\n  e.updated,\n  u.name,\n  u.surname,\n  u.username\nFROM \n    ENROLLMENTS e\n  LEFT JOIN users u ON e.id_user = u.id;"
  }, collection)

  // add field
  collection.fields.addAt(6, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_lYn3",
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
    "id": "_clone_PaKc",
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
    "id": "_clone_A2QP",
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

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user,\n  e.listKind,\n  e.created,\n  e.updated\nFROM \n    ENROLLMENTS e\n  LEFT JOIN users u ON e.id_user = u.id;"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_lYn3")

  // remove field
  collection.fields.removeById("_clone_PaKc")

  // remove field
  collection.fields.removeById("_clone_A2QP")

  return app.save(collection)
})
