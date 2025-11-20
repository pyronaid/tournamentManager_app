SELECT
  t.id,
  t.id_owner,
  t.name,
  t.capacity,
  t.date,
  t.game,
  t.state,
  t.image,
  t.preRegistrationEn,
  t.waitingListEn,
  t.address,
  t.latitude,
  t.longitude,
  t.lastUpdated_news,
  t.lastUpdated_enrollments,
  t.lastUpdated_rounds,
  t.created,
  t.updated,
  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'preregistered') as preRegisteredCount,
  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'registered') as registeredCount,
  (SELECT COUNT(*) FROM enrollments e WHERE e.id_tournament = t.id AND e.listKind = 'waiting') as waitingCount,
  'pbc_340646327' as collectionIdSource,
  json_group_array(
    json_object(
        'id', u.id
        'name', u.name,
        'surname', u.surname,
        'username', u.username
    )
  ) AS id_winner
FROM tournaments t
LEFT JOIN json_each(t.id_winner) as user_id
LEFT JOIN users u ON user_id.value = u.id
GROUP BY t.id