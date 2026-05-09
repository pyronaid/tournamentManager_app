/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2282062390");

  return app.delete(collection);
}, (app) => {
  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text3208210256",
        "max": 0,
        "min": 0,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "json568698700",
        "maxSize": 1,
        "name": "id_owner",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_2282062390",
    "indexes": [],
    "listRule": null,
    "name": "test_view",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT id, id_owner FROM TOURNAMENTS;",
    "viewRule": null
  });

  return app.save(collection);
})
