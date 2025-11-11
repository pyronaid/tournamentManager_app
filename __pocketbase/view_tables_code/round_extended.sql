SELECT
    id,
    id_tournament,
    id_owner,
    roundIndex,
    roundSize,
    roundKind,
    created,
    updated,
    matchAll,
    matchCompleted,
    (matchAll = matchCompleted) as completed,
    availablePlayers
FROM (
    SELECT
        r.id,
        r.id_tournament,
        t.id_owner,
        r.roundIndex,
        r.roundSize,
        r.roundKind,
        r.created,
        r.updated,
        COUNT(p.id) as matchAll,
        COUNT(CASE WHEN (p.winner != '' AND p.winner IS NOT NULL) OR p.doubleLoss = 1 THEN 1 END) as matchCompleted,
        SUM(
            CASE
                WHEN p.dropPlayerA != true AND p.dropPlayerB != true AND p.isBye != true THEN 2
                WHEN p.dropPlayerA != true AND p.dropPlayerB != true AND p.isBye = true THEN 1
                WHEN p.dropPlayerA != true AND p.dropPlayerB = true THEN 1
                WHEN p.dropPlayerA = true AND p.dropPlayerB != true THEN 1
                ELSE 0
            END
        ) as availablePlayers
    FROM rounds r
    LEFT JOIN pairings p ON (
        p.id_tournament = r.id_tournament
        AND p.id_round = r.id
    )
    LEFT JOIN tournaments t ON (
        t.id = r.id_tournament
    )
    GROUP BY r.id,
             r.id_tournament,
             r.roundIndex,
             r.roundSize,
             r.roundKind,
             r.created,
             r.updated
)