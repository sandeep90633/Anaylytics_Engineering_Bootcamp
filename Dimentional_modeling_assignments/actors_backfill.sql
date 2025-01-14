INSERT INTO actors_scd
WITH with_previous AS (
    SELECT 
        actor,
        quality_class,
        is_active,
        LAG(quality_class, 1) OVER(PARTITION BY actor ORDER BY current_year) AS previous_quality_class,
        LAG(is_active, 1) OVER(PARTITION BY actor ORDER BY current_year) AS previous_is_active,
        current_year
    FROM
        actors

    WHERE current_year <=2020
),
with_indicators AS (
    SELECT  
        *,
        CASE WHEN quality_class <> previous_quality_class THEN 1
            WHEN is_active <> previous_is_active THEN 1
            ELSE 0
        END AS change_indicators
    FROM
        with_previous
),
with_streaks AS (
    SELECT
        *,
        SUM(change_indicators) OVER(PARTITION BY actor ORDER BY current_year) AS streak_identifier
    FROM
        with_indicators
)

SELECT 
    actor,
    MIN(current_year) as start_year,
    MAX(current_year) as end_year,
    quality_class,
    is_active,
    2020 as current_year
FROM 
    with_streaks
GROUP BY actor, streak_identifier, quality_class, is_active
ORDER BY actor, streak_identifier