INSERT INTO actors
WITH last_year AS (
    SELECT * FROM actors
    WHERE current_year = 2020
), 
current_year AS (
    SELECT 
        actor,
        actorid,
        ARRAY_AGG(
            ROW(
                film,
                votes,
                rating,
                filmid
            )::films
        ) AS aggregated_films,
        year
    FROM actor_films
    WHERE year = 2021
    GROUP BY actor, actorid, year
)

SELECT
    COALESCE(c.actor, l.actor) AS actor,
    COALESCE(c.actorid, l.actorid) AS actorid,
    CASE 
        WHEN l.films IS NULL
        THEN c.aggregated_films
        WHEN c.year IS NOT NULL
        THEN l.films || c.aggregated_films
        ELSE l.films
    END AS films,
    CASE
        WHEN c.year IS NOT NULL THEN
            CASE 
                WHEN (SELECT AVG((s).rating) FROM unnest(c.aggregated_films) s) > 8 THEN 'star'
                WHEN (SELECT AVG((s).rating) FROM unnest(c.aggregated_films) s) > 7 THEN 'good'
                WHEN (SELECT AVG((s).rating) FROM unnest(c.aggregated_films) s) > 6 THEN 'average'
                ELSE 'bad'
            END::quality_class
        ELSE l.quality_class
    END AS quality_class,
    2021 AS current_year,
    c.year IS NOT NULL as is_active

FROM 
    last_year l
FULL OUTER JOIN
    current_year c
ON c.actor = l.actor