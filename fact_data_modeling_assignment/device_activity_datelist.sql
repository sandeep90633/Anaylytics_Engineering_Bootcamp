INSERT INTO user_devices_cumulated
WITH yesterday AS(
    SELECT
        *
    FROM
        user_devices_cumulated
    WHERE
        date = DATE '2023-01-30'
),
today AS (
    SELECT
        user_id,
        DATE(event_date) AS date_active,
        browser_type
    FROM
        deduped_users_devices
    WHERE
        (event_date = DATE '2023-01-31') AND user_id IS NOT NULL
),
extended_device_activity_dates AS (
SELECT
    COALESCE(t.user_id, y.user_id) AS user_id,
    COALESCE(t.browser_type, y.browser_type) AS browser_type,
    CASE 
        WHEN y.date IS NULL
            THEN ARRAY[t.date_active]
        WHEN t.date_active IS NULL
            THEN y.device_activity_dates
        ELSE ARRAY[t.date_active] || y.device_activity_dates
    END AS device_activity_dates,
    COALESCE(t.date_active, y.date + INTERVAL '1 DAY') AS date
FROM
    today t
FULL OUTER JOIN
    yesterday y
ON
    t.user_id = y.user_id AND t.browser_type = y.browser_type
),
row_number AS (
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id, browser_type, date) AS row_number
FROM
    extended_device_activity_dates
)

SELECT
    user_id,
    browser_type,
    device_activity_dates,
    date
FROM
    row_number
WHERE row_number=1