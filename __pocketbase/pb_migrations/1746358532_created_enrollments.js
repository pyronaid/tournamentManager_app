/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "hidden": false,
        "id": "text3208210256",
        "max": 15,
        "min": 15,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
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
      },
      {
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
      },
      {
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
      },
      {
        "hidden": false,
        "id": "autodate2990389176",
        "name": "created",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "hidden": false,
        "id": "autodate3332085495",
        "name": "updated",
        "onCreate": true,
        "onUpdate": true,
        "presentable": false,
        "system": false,
        "type": "autodate"
      }
    ],
    "id": "pbc_1009377862",
    "indexes": [
      "CREATE UNIQUE INDEX `idx_XKRieZIyAu` ON `enrollments` (\n  `id_tournament`,\n  `id_user`\n)",
      "CREATE INDEX `idx_wVYqZLVPsG` ON `enrollments` (`id_tournament`)"
    ],
    "listRule": null,
    "name": "enrollments",
    "system": false,
    "type": "base",
    "updateRule": null,
    "viewRule": null
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1009377862");

  return app.delete(collection);
})
