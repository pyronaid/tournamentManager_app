/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2282062390")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  id,\n  id_owner,\n  name,\n  capacity,\n  date,\n  game,\n  state,\n  image,\n  pre_registration_en,\n  waiting_list_en,\n  address,\n  latitude,\n  longitude,\n  id_winner\nFROM \n    TOURNAMENTS;"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2282062390")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  t.id,\n  t.id_owner,\n  t.name,\n  t.capacity,\n  t.date,\n  t.game,\n  t.state,\n  t.image,\n  t.pre_registration_en,\n  t.waiting_list_en,\n  t.address,\n  t.latitude,\n  t.longitude,\n  t.id_winner\nFROM \n    TOURNAMENTS t;"
  }, collection)

  return app.save(collection)
})
