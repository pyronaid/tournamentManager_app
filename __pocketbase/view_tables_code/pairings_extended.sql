SELECT
  p.id,
  p.id_tournament,
  p.id_round,
  p.playerA,
  p.dropPlayerA,
  p.playerB,
  p.dropPlayerB,
  p.isBye,
  p.noShow,
  p.tableIndex,
  p.winner,
  p.doubleLoss,
  p.created,
  p.updated,
  r.roundIndex,
  u1.name as namePlayerA,
  u1.surname as surnamePlayerA,
  u1.username as usernamePlayerA,
  u2.name as namePlayerB,
  u2.surname as surnamePlayerB,
  u2.username as usernamePlayerB
FROM
    pairings p
  LEFT JOIN rounds r ON p.id_round = r.id
  LEFT JOIN users u1 ON p.playerA = u1.id
  LEFT JOIN users u2 ON p.playerB = u2.id;