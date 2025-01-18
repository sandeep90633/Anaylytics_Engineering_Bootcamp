WITH agg AS (
    SELECT 
        host,
        date_trunc('month', month) AS month_start,
        ARRAY[SUM(hit_array[1]),
                SUM(hit_array[2]),
                SUM(hit_array[3]),
                SUM(hit_array[4]),
                SUM(hit_array[5])] AS summed_hit_array,
        ARRAY[SUM(unique_visitors_array[1]),
                SUM(unique_visitors_array[2]),
                SUM(unique_visitors_array[3]),
                SUM(unique_visitors_array[4]),
                SUM(unique_visitors_array[5])] AS summed_unique_users_array    
    FROM 
        host_activity_reduced
    GROUP BY host, month
)

SELECT
    host,
    month_start + CAST(CAST(index-1 AS TEXT) || ' DAY' AS INTERVAL) AS date,
    daily_hits,
    unique_users
FROM
    agg
CROSS JOIN 
    UNNEST(agg.summed_hit_array, agg.summed_unique_users_array) WITH ORDINALITY as a(daily_hits, unique_users, index)