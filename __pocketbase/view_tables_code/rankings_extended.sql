WITH rankings_ext AS (
  SELECT
    r.id,
    r.id_user,
    r.id_tournament,
    r.id_round,
    ro.roundIndex,
    r.isDrop,
    r.created,
    r.updated
  FROM rankings r
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
    r.id_round,
    r.roundIndex as current_round_index,
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
    uo.current_round_index,
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
    AND p.roundIndex <= uo.current_round_index  -- Only consider completed/current rounds
    AND (p.winner != '' OR p.doubleLoss = 1)
  )
),


rankings_focused_user AS (
 SELECT
    r.id,
    r.id_tournament,
    r.id_round,
    r.roundIndex as current_round_index,
    r.id_user,
    COUNT(CASE WHEN p.winner = r.id_user THEN 1 END) as user_wins,
    COUNT(CASE WHEN (p.winner = r.id_user AND p.noShow = true)  THEN 1 END) as user_wins_no_show,
    COUNT(CASE WHEN (p.winner = r.id_user AND p.isBye = true)  THEN 1 END) as user_wins_bye,
    SUM(CASE WHEN ((p.winner != '' AND p.winner != r.id_user) OR p.doubleLoss = true) THEN (p.roundIndex * p.roundIndex) ELSE 0 END) as user_sum_lose_index,
    COUNT(p.id) as user_matches
  FROM rankings_ext r
  LEFT JOIN pairings_ext p ON (
    p.id_tournament = r.id_tournament
    AND (p.playerA = r.id_user OR p.playerB = r.id_user)
    -- AND p.isBye = false
    AND p.roundIndex <= r.roundIndex  -- Only consider completed/current rounds
    AND (p.winner != '' OR p.doubleLoss = 1)
  )
  GROUP BY r.id, r.id_tournament, r.id_round, current_round_index, r.id_user
),

rankings_focused_oppo AS (
    SELECT
      r.id,
      r.id_tournament,
      r.id_round,
      current_round_index,
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
        AND p.roundIndex <= r.current_round_index  -- Only consider completed/current rounds
        AND (p.winner != '' OR p.doubleLoss = 1)
    )
    WHERE r.opponent_id NOT LIKE '000000000000000%'
    GROUP BY r.id, r.id_tournament, r.id_round, current_round_index, r.id_user
),

rankings_focused_oppoppo AS (
    SELECT
          r.id,
          r.id_tournament,
          r.id_round,
          current_round_index,
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
            AND p.roundIndex <= r.current_round_index  -- Only consider completed/current rounds
            AND (p.winner != '' OR p.doubleLoss = 1)
        )
        WHERE r.opponent_id NOT LIKE '000000000000000%' AND r.opponent_opponent_id NOT LIKE '000000000000000%'
        GROUP BY r.id, r.id_tournament, r.id_round, current_round_index, r.id_user
)


    SELECT
        r.id,
        r.id_tournament,
        r.id_round,
        r.current_round_index,
        r.id_user,
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
        oppopponent_win_percentage
    FROM rankings_focused_user r
    LEFT JOIN rankings_focused_oppo ro
    ON (
        r.id = ro.id
        AND r.id_tournament = ro.id_tournament
        AND r.id_round = ro.id_round
        AND r.current_round_index = ro.current_round_index
        AND r.id_user = ro.id_user
    )
    LEFT JOIN rankings_focused_oppoppo roo
    ON (
        r.id = roo.id
        AND r.id_tournament = roo.id_tournament
        AND r.id_round = roo.id_round
        AND r.current_round_index = roo.current_round_index
        AND r.id_user = roo.id_user
    )



/*rankings_focused_user DEBUG QUERY
 SELECT
    r.id,
    r.id_tournament,
    r.id_round,
    r.roundIndex as current_round_index,
    r.id_user,
    p.winner,
    p.noShow,
    p.isBye,
    p.doubleLoss,
    p.id as pid
  FROM rankings_ext r
  LEFT JOIN pairings_ext p ON (
    p.id_tournament = r.id_tournament
    AND (p.playerA = r.id_user OR p.playerB = r.id_user)
    -- AND p.isBye = false
    AND p.roundIndex <= r.roundIndex  -- Only consider completed/current rounds
    AND (p.winner != '' OR p.doubleLoss = 1)
  )
*/
/*rankings_focused_oppo DEBUG QUERY
SELECT
  r.id,
  r.id_tournament,
  r.id_round,
  current_round_index,
  r.id_user,
  r.opponent_id,
  p.winner,
  p.id_round as pid_round
FROM user_opponents r
LEFT JOIN pairings_ext p ON (
    r.id_tournament = p.id_tournament
    AND (CONCAT(p.playerA, p.id_round) = r.opponent_id OR CONCAT(p.playerB, p.id_round) = r.opponent_id)
    -- AND p.isBye = false
    AND p.roundIndex <= r.current_round_index  -- Only consider completed/current rounds
    AND (p.winner != '' OR p.doubleLoss = 1)
)
WHERE r.opponent_id !~ '000000000000000'
    AND r.id_user = 'zi1tw68velk0b2g'

SELECT
      r.id,
      r.id_tournament,
      r.id_round,
      current_round_index,
      r.id_user,
      COUNT(DISTINCT r.opponent_id) as opponent_total_matches,
      COUNT(CASE WHEN CONCAT(p.winner, p.id_round) = r.opponent_id THEN 1 END) as opponent_wins,
      ROUND(
        CASE
          WHEN COUNT(DISTINCT r.opponent_id) > 0
          THEN (COUNT(CASE WHEN CONCAT(p.winner, p.id_round) = r.opponent_id THEN 1 END) * 100.0 / COUNT(DISTINCT r.opponent_id))
          ELSE 0
        END, 5
      ) as opponent_win_percentage
    FROM user_opponents r
    LEFT JOIN pairings_ext p ON (
        p.id_tournament = r.id_tournament
        AND (CONCAT(p.playerA, p.id_round) = r.opponent_id OR CONCAT(p.playerB, p.id_round) = r.opponent_id)
        -- AND p.isBye = false
        AND p.roundIndex <= r.current_round_index  -- Only consider completed/current rounds
        AND (p.winner != '' OR p.doubleLoss = 1)
    )
    WHERE r.opponent_id !~ '000000000000000'  AND r.id_user = 'zi1tw68velk0b2g'
    GROUP BY r.id, r.id_tournament, r.id_round, current_round_index, r.id_user
*/