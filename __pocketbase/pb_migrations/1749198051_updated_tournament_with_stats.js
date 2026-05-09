/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2560115994")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  t.id,\n  t.id_owner,\n  t.name,\n  t.capacity,\n  t.date,\n  t.game,\n  t.state,\n  t.image,\n  t.preRegistrationEn,\n  t.waitingListEn,\n  t.address,\n  t.latitude,\n  t.longitude,\n  t.id_winner,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'preregistered') as preRegisteredCount,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'registered') as registeredCount,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'waiting') as waitingCount\nFROM \n    TOURNAMENTS t;"
  }, collection)

  // remove field
  collection.fields.removeById("json3071060472")

  // remove field
  collection.fields.removeById("json1231498413")

  // remove field
  collection.fields.removeById("json2812608690")

  // remove field
  collection.fields.removeById("json148327038")

  // remove field
  collection.fields.removeById("json1789685542")

  // add field
  collection.fields.addAt(8, new Field({
    "hidden": false,
    "id": "json1473431790",
    "maxSize": 1,
    "name": "preRegistrationEn",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "json893485489",
    "maxSize": 1,
    "name": "waitingListEn",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(14, new Field({
    "hidden": false,
    "id": "json499882555",
    "maxSize": 1,
    "name": "preRegisteredCount",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(15, new Field({
    "hidden": false,
    "id": "json524218978",
    "maxSize": 1,
    "name": "registeredCount",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(16, new Field({
    "hidden": false,
    "id": "json3104208190",
    "maxSize": 1,
    "name": "waitingCount",
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
    "viewQuery": "SELECT \n  t.id,\n  t.id_owner,\n  t.name,\n  t.capacity,\n  t.date,\n  t.game,\n  t.state,\n  t.image,\n  t.pre_registration_en,\n  t.waiting_list_en,\n  t.address,\n  t.latitude,\n  t.longitude,\n  t.id_winner,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'preregistered') as pre_registered_count,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'registered') as registered_count,\n  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'waiting') as waiting_count\nFROM \n    TOURNAMENTS t;"
  }, collection)

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
  collection.fields.addAt(14, new Field({
    "hidden": false,
    "id": "json2812608690",
    "maxSize": 1,
    "name": "pre_registered_count",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(15, new Field({
    "hidden": false,
    "id": "json148327038",
    "maxSize": 1,
    "name": "registered_count",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(16, new Field({
    "hidden": false,
    "id": "json1789685542",
    "maxSize": 1,
    "name": "waiting_count",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // remove field
  collection.fields.removeById("json1473431790")

  // remove field
  collection.fields.removeById("json893485489")

  // remove field
  collection.fields.removeById("json499882555")

  // remove field
  collection.fields.removeById("json524218978")

  // remove field
  collection.fields.removeById("json3104208190")

  return app.save(collection)
})
