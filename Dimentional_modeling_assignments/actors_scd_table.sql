CREATE TABLE actors_scd(
    actor TEXT,
    start_year INTEGER,
    end_year INTEGER,
    quality_class quality_class,
    is_active BOOLEAN,
    current_year INTEGER,
    PRIMARY KEY(actor,start_year)
)