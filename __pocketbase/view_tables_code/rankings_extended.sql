WITH rankings_ext AS (
  SELECT
    r.id,
    r.id_user,
    u.name as userName,
    u.surname as userSurname,
    u.username as userUsername,
    r.id_tournament,
    t.id_owner,
    r.id_round,
    ro.roundIndex,
    r.isDrop,
    r.created,
    r.updated
  FROM rankings r
  LEFT JOIN tournaments t ON (
      t.id = r.id_tournament
  )
  LEFT JOIN users u ON (
        u.id = r.id_user
    )
  INNER JOIN rounds ro ON r.id_round = ro.id
),


pairings_ext AS (
  SELECT
    p.id,
    p.id_tournament,
    p.id_round,
    ro.roundIndex,
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
    p.updated
  FROM pairings p
  INNER JOIN rounds ro ON p.id_round = ro.id
),


user_opponents AS (
  -- Get all opponents for each user in the specified tournament/round
  -- Only consider opponents from rounds up to the current round
  SELECT
    r.id,
    r.id_user,
    r.id_tournament,
    r.id_owner,
    r.id_round,
    r.roundIndex as currentRoundIndex,
    CASE
      WHEN p.playerA = r.id_user THEN CONCAT(p.playerB, p.id_round)
      WHEN p.playerB = r.id_user THEN CONCAT(p.playerA, p.id_round)
      ELSE NULL
    END as opponent_id
  FROM rankings_ext r
  LEFT JOIN pairings_ext p ON (
    p.id_tournament = r.id_tournament
    AND (p.playerA = r.id_user OR p.playerB = r.id_user)
    --AND p.isBye = false
    AND p.roundIndex <= r.roundIndex  -- Only consider completed/current rounds
    AND (p.winner != '' OR p.doubleLoss = 1)
  )
),


user_opponent_opponents AS (
  -- Get all opponents for each user in the specified tournament/round
  -- Only consider opponents from rounds up to the current round
  SELECT
    uo.id,
    uo.id_user,
    uo.id_tournament,
    uo.id_round,
    uo.currentRoundIndex,
    uo.opponent_id,
    CASE
      WHEN CONCAT(p.playerA, p.id_round) = uo.opponent_id THEN CONCAT(p.playerB, p.id_round)
      WHEN CONCAT(p.playerB, p.id_round) = uo.opponent_id THEN CONCAT(p.playerA, p.id_round)
      ELSE NULL
    END as opponent_opponent_id
  FROM user_opponents uo
  LEFT JOIN pairings_ext p ON (
    p.id_tournament = uo.id_tournament
    AND (CONCAT(p.playerA, p.id_round) = uo.opponent_id OR CONCAT(p.playerB, p.id_round) = uo.opponent_id)
    --AND p.isBye = false
    AND p.roundIndex <= uo.currentRoundIndex  -- Only consider completed/current rounds
    AND (p.winner != '' OR p.doubleLoss = 1)
  )
),


rankings_focused_user AS (
 SELECT
    r.id,
    r.id_tournament,
    r.id_owner,
    r.id_round,
    r.roundIndex as currentRoundIndex,
    r.id_user,
    r.userName,
    r.userSurname,
    r.userUsername,
    COUNT(
        CASE
            WHEN p.playerA = r.id_user AND p.dropPlayerA = true THEN 1
            WHEN p.playerB = r.id_user AND p.dropPlayerB = true THEN 1
            ELSE 0
        END
    ) > 0 as isDrop,
    COUNT(CASE WHEN p.winner = r.id_user THEN 1 END) as user_wins,
    COUNT(CASE WHEN (p.winner = r.id_user AND p.noShow = true)  THEN 1 END) as user_wins_no_show,
    COUNT(CASE WHEN (p.winner = r.id_user AND p.isBye = true)  THEN 1 END) as user_wins_bye,
    SUM(CASE WHEN ((p.winner != '' AND p.winner != r.id_user) OR p.doubleLoss = true) THEN (p.roundIndex * p.roundIndex) ELSE 0 END) as user_sum_lose_index,
    COUNT(p.id) as user_matches,
    r.created,
    r.updated
  FROM rankings_ext r
  LEFT JOIN pairings_ext p ON (
    p.id_tournament = r.id_tournament
    AND (p.playerA = r.id_user OR p.playerB = r.id_user)
    -- AND p.isBye = false
    AND p.roundIndex <= r.roundIndex  -- Only consider completed/current rounds
    AND (p.winner != '' OR p.doubleLoss = 1)
  )
  GROUP BY r.id, r.id_tournament, r.id_round, currentRoundIndex, r.id_user
),

rankings_focused_oppo AS (
    SELECT
      r.id,
      r.id_tournament,
      r.id_round,
      currentRoundIndex,
      r.id_user,
      COUNT(DISTINCT r.opponent_id) as opponent_total_matches,
      COUNT(CASE WHEN CONCAT(p.winner, p.id_round) = r.opponent_id THEN 1 END) as opponent_wins,
          ROUND(
            CASE
              WHEN COUNT(DISTINCT r.opponent_id) > 0
              THEN (COUNT(CASE WHEN CONCAT(p.winner, p.id_round) = r.opponent_id THEN 1 END) * 100.0 / COUNT(DISTINCT r.opponent_id))
              ELSE 0
            END, 3
          ) as opponent_win_percentage
    FROM user_opponents r
    LEFT JOIN pairings_ext p ON (
        p.id_tournament = r.id_tournament
        AND (CONCAT(p.playerA, p.id_round) = r.opponent_id OR CONCAT(p.playerB, p.id_round) = r.opponent_id)
        -- AND p.isBye = false
        AND p.roundIndex <= r.currentRoundIndex  -- Only consider completed/current rounds
        AND (p.winner != '' OR p.doubleLoss = 1)
    )
    WHERE r.opponent_id NOT LIKE '000000000000000%'
    GROUP BY r.id, r.id_tournament, r.id_round, currentRoundIndex, r.id_user
),

rankings_focused_oppoppo AS (
    SELECT
          r.id,
          r.id_tournament,
          r.id_round,
          currentRoundIndex,
          r.id_user,
          COUNT(DISTINCT r.opponent_opponent_id) as oppopponent_total_matches,
          COUNT(CASE WHEN CONCAT(p.winner, p.id_round) = r.opponent_opponent_id THEN 1 END) as oppopponent_wins,
          ROUND(
            CASE
              WHEN COUNT(DISTINCT r.opponent_opponent_id) > 0
              THEN (COUNT(CASE WHEN CONCAT(p.winner, p.id_round) = r.opponent_opponent_id THEN 1 END) * 100.0 / COUNT(DISTINCT r.opponent_opponent_id))
              ELSE 0
            END, 3
          ) as oppopponent_win_percentage
        FROM user_opponent_opponents r
        LEFT JOIN pairings_ext p ON (
            p.id_tournament = r.id_tournament
            AND (CONCAT(p.playerA, p.id_round) = r.opponent_opponent_id OR CONCAT(p.playerB, p.id_round) = r.opponent_opponent_id)
            -- AND p.isBye = false
            AND p.roundIndex <= r.currentRoundIndex  -- Only consider completed/current rounds
            AND (p.winner != '' OR p.doubleLoss = 1)
        )
        WHERE r.opponent_id NOT LIKE '000000000000000%' AND r.opponent_opponent_id NOT LIKE '000000000000000%'
        GROUP BY r.id, r.id_tournament, r.id_round, currentRoundIndex, r.id_user
)


    SELECT
        r.id,
        r.id_tournament,
        r.id_owner,
        r.id_round,
        r.currentRoundIndex,
        r.id_user,
        r.userName,
        r.userSurname,
        r.userUsername,
        r.isDrop,
        (user_wins * 3) as points,
        (CASE WHEN opponent_win_percentage IS NULL
             THEN 0
             ELSE MAX(opponent_win_percentage, 33.333)
        END) as T1,
        (CASE WHEN oppopponent_win_percentage IS NULL
             THEN 0
             ELSE MAX(oppopponent_win_percentage, 33.333)
        END) as T2,
        user_sum_lose_index as T3,
        user_wins,
        user_wins_no_show,
        user_wins_bye,
        user_sum_lose_index,
        user_matches,
        opponent_total_matches,
        opponent_wins,
        opponent_win_percentage,
        oppopponent_total_matches,
        oppopponent_wins,
        oppopponent_win_percentage,
        r.created,
        r.updated
    FROM rankings_focused_user r
    LEFT JOIN rankings_focused_oppo ro
    ON (
        r.id = ro.id
        AND r.id_tournament = ro.id_tournament
        AND r.id_round = ro.id_round
        AND r.currentRoundIndex = ro.currentRoundIndex
        AND r.id_user = ro.id_user
    )
    LEFT JOIN rankings_focused_oppoppo roo
    ON (
        r.id = roo.id
        AND r.id_tournament = roo.id_tournament
        AND r.id_round = roo.id_round
        AND r.currentRoundIndex = roo.currentRoundIndex
        AND r.id_user = roo.id_user
    )