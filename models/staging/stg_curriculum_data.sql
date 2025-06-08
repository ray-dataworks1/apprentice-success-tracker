CREATE OR REPLACE VIEW stg_curriculum AS
WITH raw AS (
  SELECT
    curriculum_version,
    change_date,
    change_type,
    description
  FROM dim_curriculum
),
cleaned AS (
  SELECT
    TRIM(curriculum_version) AS curriculum_version,

    change_date,
    LOWER(TRIM(change_type)) AS change_type_cleaned,
    INITCAP(TRIM(description)) AS description_cleaned,

    -- Optional flag: major format change
    CASE 
      WHEN LOWER(change_type) LIKE '%revamp%' OR LOWER(change_type) LIKE '%overhaul%' 
        THEN TRUE
      ELSE FALSE
    END AS is_major_change
  FROM raw
)
SELECT *
FROM cleaned
WHERE curriculum_version ~ '^V\d$'; -- Ensures only V1, V2, V3 etc. are accepted
-- Exclude any curriculum versions that do not match the expected format
-- and ensure that the curriculum version is not null