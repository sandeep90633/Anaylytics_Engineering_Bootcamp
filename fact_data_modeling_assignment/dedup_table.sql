CREATE TABLE deduped_users_devices (
    event_date DATE,
    user_id TEXT,
    device_id TEXT,
    browser_type TEXT
)

INSERT INTO deduped_users_devices
WITH deduped AS (
    SELECT
        DATE(e.event_time) AS event_date,
        e.user_id,
        d.device_id,
        d.browser_type,
        ROW_NUMBER() OVER(PARTITION BY DATE(e.event_time),d.device_id,e.user_id,d.browser_type) as row_number
    FROM
        devices d
    JOIN 
        events e
    ON  
        d.device_id = e.device_id
)

SELECT
    event_date,
    user_id,
    device_id,
    browser_type
FROM
    deduped
WHERE
    row_number =1