/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1009377862")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_XKRieZIyAu` ON `enrollments` (\n  `id_tournament`,\n  `id_user`\n)",
      "CREATE INDEX `idx_wVYqZLVPsG` ON `enrollments` (`id_tournament`)",
      "CREATE INDEX `idx_OWzqIl1g5q` ON `enrollments` (`id_user`)"
    ]
  }, collection)

  // update field
  collection.fields.addAt(1, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_340646327",
    "hidden": false,
    "id": "relation416626702",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "id_tournament",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  // update field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "_pb_users_auth_",
    "hidden": false,
    "id": "relation112446027",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "id_user",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  // update field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "select3340670512",
    "maxSelect": 1,
    "name": "listKind",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "registered",
      "preregistered",
      "waiting"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1009377862")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_XKRieZIyAu` ON `enrollments` (\n  `id_tournament`,\n  `id_user`\n)",
      "CREATE INDEX `idx_wVYqZLVPsG` ON `enrollments` (`id_tournament`)"
    ]
  }, collection)

  // update field
  collection.fields.addAt(1, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_340646327",
    "hidden": false,
    "id": "relation416626702",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "id_tournament",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // update field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "_pb_users_auth_",
    "hidden": false,
    "id": "relation112446027",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "id_user",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // update field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "select3340670512",
    "maxSelect": 1,
    "name": "listKind",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "registered",
      "preregistered",
      "waiting"
    ]
  }))

  return app.save(collection)
})
