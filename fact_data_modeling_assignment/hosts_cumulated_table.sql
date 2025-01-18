CREATE TABLE hosts_cumulated (
    host TEXT,
    date DATE,
    host_metric_datelist DATE[],
    PRIMARY KEY(host, date)
)


