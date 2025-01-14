-- SELECT * FROM player_seasons
-- LIMIT 10;

-- CREATE TYPE season_stats AS (
--     season INTEGER,
--     gp INTEGER,
--     pts REAL,
--     reb REAL,
--     ast REAL
-- )

-- CREATE TYPE scoring_class AS ENUM('star','good','avg','bad');

-- DROP TABLE players;

-- CREATE TABLE players (
--     player_name TEXT,
--     height TEXT,
--     college TEXT,
--     country TEXT,
--     draft_year TEXT,
--     draft_number TEXT,
--     draft_round TEXT,
--     season_stats season_stats[],
--     scoring_class scoring_class,
--     years_since_last_season INTEGER,
--     current_season INTEGER,
--     is_active BOOLEAN,
--     PRIMARY KEY(player_name, current_season)
-- );

INSERT INTO players
WITH yesterday AS (
    SELECT * FROM players
    WHERE current_season = 2021
),
today AS (
    SELECT * FROM player_seasons
    WHERE season = 2022
)

SELECT 
    COALESCE(t.player_name, y.player_name) AS player_name,
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_number, y.draft_number) AS draft_number,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    CASE 
        WHEN y.season_stats IS NULL 
        THEN ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats]
        WHEN t.season IS NOT NULL 
        THEN y.season_stats || ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats]
        ELSE y.season_stats
    END AS season_stats,
    CASE 
        WHEN t.season IS NOT NULL THEN
            CASE WHEN t.pts > 20 THEN 'star'
                WHEN t.pts > 15 THEN 'good'
                WHEN t.pts > 10 THEN 'avg'
                ELSE 'bad'
            END::scoring_class
        ELSE y.scoring_class
    END as scoring_class,
    CASE 
        WHEN t.season IS NOT NULL THEN 0 
        ELSE y.years_since_last_season + 1 
    END AS years_since_last_season,
    COALESCE(t.season, y.current_season +1) as current_season,
    CASE 
        WHEN t.season IS NOT NULL THEN TRUE
        ELSE FALSE
    END AS is_active

FROM 
    today t 
FULL OUTER JOIN 
    yesterday y
ON
    t.player_name = y.player_name;