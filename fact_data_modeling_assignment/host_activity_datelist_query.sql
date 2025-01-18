INSERT INTO hosts_cumulated
WITH yesterday AS (
    SELECT
        *
    FROM
        hosts_cumulated
    WHERE date = DATE('2023-01-02')
),
today_hosts AS (
    SELECT 
        DISTINCT ON (host, DATE(event_time)) 
        host, 
        DATE(event_time) AS today_date
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-03')
)

SELECT  
    COALESCE(t.host, y.host) AS host,
    COALESCE(t.today_date, y.date + INTERVAL '1 DAY') AS date,
    CASE
        WHEN y.host_metric_datelist IS NULL
            THEN ARRAY[t.today_date]
        WHEN t.host IS NULL
            THEN y.host_metric_datelist
        ELSE y.host_metric_datelist || ARRAY[t.today_date]
    END AS host_metric_datelist
FROM
    today_hosts t
FULL OUTER JOIN
    yesterday y
ON t.host = y.host