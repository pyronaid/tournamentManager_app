SELECT
    r.id,
    r.id_tournament,
    r.roundIndex,
    r.roundSize,
    r.roundKind,
    r.completed,
    r.created,
    r.updated,
    COUNT(p.id) as matchAll,
    COUNT(CASE WHEN (p.winner != '' AND p.winner NOT NULL) OR p.doubleLoss = 1  THEN 1 END) as matchCompleted
FROM rounds r
LEFT JOIN pairings p ON (
    p.id_tournament = r.id_tournament
    AND p.id_round = r.id
)
GROUP BY r.id,
             r.id_tournament,
             r.roundIndex,
             r.roundSize,
             r.roundKind,
             r.completed,
             r.created,
             r.updated