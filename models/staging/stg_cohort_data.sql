CREATE OR REPLACE VIEW stg_cohort AS
WITH raw AS (
  SELECT
    cohort_id,
    cohort_name,
    start_date,
    end_date,
    curriculum_version
  FROM dim_cohort
),
validated AS (
  SELECT
    cohort_id,
    cohort_name,
    start_date,
    end_date,
    curriculum_version,

    -- Extract season from cohort_name
    LOWER(SPLIT_PART(cohort_name, ' ', 1)) AS cohort_season,
    EXTRACT(YEAR FROM start_date) AS cohort_year,

    -- Surrogate cohort key (optional if not needed now)
    ROW_NUMBER() OVER (PARTITION BY cohort_id ORDER BY start_date DESC) AS cohort_surrogate
  FROM raw
  WHERE cohort_id IS NOT NULL
)
SELECT *
FROM validated
WHERE 
  cohort_season IN ('winter', 'spring', 'summer', 'autumn')
  AND start_date < end_date
  AND cohort_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 5;
