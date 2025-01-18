WITH users AS (
    SELECT * FROM user_devices_cumulated
    WHERE date = DATE '2023-01-31'
),
generate_series AS (
    SELECT
        *
    FROM
        generate_series(DATE('2023-01-01'),DATE('2023-01-31'), INTERVAL '1 DAY') AS generated_date
),
placeholder_ints AS (
    SELECT
        user_id,
        CASE
            WHEN device_activity_dates @> ARRAY[DATE(generated_date)]
                THEN CAST(POW(2,32 - (date - DATE(generated_date))) AS BIGINT)
            ELSE 0
        END AS placeholder_int_value
    FROM
        users
    CROSS JOIN
        generate_series
)
SELECT
    user_id,
    CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32)) AS datelist_int
FROM
    placeholder_ints
GROUP BY
    user_id