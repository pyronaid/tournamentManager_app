SELECT
  e.id,
  e.id_tournament,
  e.id_user,
  e.listKind,
  e.created,
  e.updated,
  u.name,
  u.surname,
  u.username,
  t.id_owner
FROM
    enrollments e
  LEFT JOIN users u ON e.id_user = u.id
  LEFT JOIN tournament_with_stats t ON e.id_tournament = t.id;