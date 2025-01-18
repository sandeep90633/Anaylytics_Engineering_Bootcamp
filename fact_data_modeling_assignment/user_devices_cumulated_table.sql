CREATE TABLE user_devices_cumulated (
    user_id TEXT,
    browser_type TEXT,
    device_activity_dates date[],
    date DATE,
    PRIMARY KEY (user_id, browser_type, date)
)