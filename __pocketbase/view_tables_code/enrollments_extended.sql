SELECT
  e.id,
  e.id_tournament,
  e.id_user,
  e.listKind,
  e.decklist,
  e.decklistImage,
  e.created,
  e.updated,
  u.name,
  u.surname,
  u.username,
  t.id_owner,
  'pbc_1009377862' as collectionIdSource
FROM
    enrollments e
  LEFT JOIN users u ON e.id_user = u.id
  LEFT JOIN tournament_with_stats t ON e.id_tournament = t.id;