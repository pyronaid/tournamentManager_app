/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user,\n  e.listKind,\n  e.created,\n  e.updated\nFROM \n    ENROLLMENTS e\n  LEFT JOIN users u ON e.id_user = u.id;"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_745506307")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT \n  e.id,\n  e.id_tournament,\n  e.id_user,\n  e.listKind,\n  e.created,\n  e.updated\nFROM \n    ENROLLMENTS e;"
  }, collection)

  return app.save(collection)
})
