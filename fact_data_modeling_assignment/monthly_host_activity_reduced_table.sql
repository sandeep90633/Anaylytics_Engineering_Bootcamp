-- CREATE TABLE host_activity_reduced (
--     month DATE,
--     host TEXT,
--     hit_array REAL[],
--     unique_visitors_array REAL[],
--     PRIMARY KEY(month, host)
-- )

INSERT INTO host_activity_reduced
WITH yesterday AS (
    SELECT
        *
    FROM
        host_activity_reduced
    WHERE DATE(month) = DATE('2023-01-01')
),
today AS(
    SELECT
        host,
        DATE(event_time) AS today_date,
        COUNT(DISTINCT user_id) AS unique_users_hits_count,
        COUNT(1) AS number_of_hits
    FROM
        events
    WHERE DATE(event_time) = DATE('2023-01-01') AND user_id IS NOT NULL
    GROUP BY host, DATE(event_time)
)

SELECT
    COALESCE(y.month, DATE(date_trunc('month', t.today_date))) as month,
    COALESCE(t.host, y.host) AS host,
    CASE
        WHEN y.hit_array IS NOT NULL
            THEN y.hit_array || ARRAY[COALESCE(t.number_of_hits,0)]
        WHEN y.hit_array IS NULL
            THEN ARRAY_FILL(0, ARRAY[COALESCE(t.today_date - DATE(DATE_TRUNC('month', t.today_date)), 0)]) || ARRAY[COALESCE(t.number_of_hits,0)]
    END AS hit_array,
    CASE
        WHEN y.unique_visitors_array IS NOT NULL
            THEN y.unique_visitors_array || ARRAY[COALESCE(t.unique_users_hits_count,0)]
        WHEN y.unique_visitors_array IS NULL
            THEN ARRAY_FILL(0, ARRAY[COALESCE(t.today_date - DATE(DATE_TRUNC('month', t.today_date)), 0)]) || ARRAY[COALESCE(t.unique_users_hits_count,0)]
    END AS unique_visitors_array
FROM
    today t
FULL OUTER JOIN
    yesterday y
ON t.host = y.host

ON CONFLICT (month, host)
DO UPDATE 
    SET hit_array = EXCLUDED.hit_array,
    unique_visitors_array = EXCLUDED.unique_visitors_array;