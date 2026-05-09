/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2560115994")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  t.id,\n  t.id_owner,\n  t.name,\n  t.capacity,\n  t.date,\n  t.game,\n  t.state,\n  t.image,\n  t.preRegistrationEn,\n  t.waitingListEn,\n  t.address,\n  t.latitude,\n  t.longitude,\n  t.id_winner,\n  t.created,\n  t.updated,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'preregistered') as preRegisteredCount,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'registered') as registeredCount,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'waiting') as waitingCount\nFROM \n    TOURNAMENTS t;"
  }, collection)

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

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2560115994")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  t.id,\n  t.id_owner,\n  t.name,\n  t.capacity,\n  t.date,\n  t.game,\n  t.state,\n  --t.image,\n  t.preRegistrationEn,\n  t.waitingListEn,\n  t.address,\n  t.latitude,\n  t.longitude,\n  t.id_winner,\n  t.created,\n  t.updated,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'preregistered') as preRegisteredCount,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'registered') as registeredCount,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'waiting') as waitingCount\nFROM \n    TOURNAMENTS t;"
  }, collection)

  // remove field
  collection.fields.removeById("json3309110367")

  return app.save(collection)
})
