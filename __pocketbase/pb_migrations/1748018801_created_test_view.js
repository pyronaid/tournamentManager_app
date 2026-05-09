/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
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
      },
      {
        "hidden": false,
        "id": "json1579384326",
        "maxSize": 1,
        "name": "name",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json3051925876",
        "maxSize": 1,
        "name": "capacity",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json2862495610",
        "maxSize": 1,
        "name": "date",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json590033292",
        "maxSize": 1,
        "name": "game",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json2744374011",
        "maxSize": 1,
        "name": "state",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json3309110367",
        "maxSize": 1,
        "name": "image",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json3071060472",
        "maxSize": 1,
        "name": "pre_registration_en",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json1231498413",
        "maxSize": 1,
        "name": "waiting_list_en",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json223244161",
        "maxSize": 1,
        "name": "address",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json1092145443",
        "maxSize": 1,
        "name": "latitude",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json2246143851",
        "maxSize": 1,
        "name": "longitude",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json717346275",
        "maxSize": 1,
        "name": "id_winner",
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
    "viewQuery": "SELECT \n  t.id,\n  t.id_owner,\n  t.name,\n  t.capacity,\n  t.date,\n  t.game,\n  t.state,\n  t.image,\n  t.pre_registration_en,\n  t.waiting_list_en,\n  t.address,\n  t.latitude,\n  t.longitude,\n  t.id_winner\nFROM \n    TOURNAMENTS t;",
    "viewRule": null
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2282062390");

  return app.delete(collection);
})
