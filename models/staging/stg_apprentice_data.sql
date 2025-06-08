-- This SQL script serves as the cleaned stage table for the apprentice data.
-- It selects relevant columns from the dimension table dim_apprentice.
CREATE OR REPLACE VIEW stg_apprentice_data AS
WITH raw AS (
  SELECT
    apprentice_id,
    gender,
    age,
    ethnicity,
    socioeconomic_status,
    neurodivergent_or_disabled,
    location,
    cohort_id
  FROM dim_apprentice
),
cleaned AS (
  SELECT
    apprentice_id,
    
    -- Apprentice ID validation
    CASE 
      WHEN apprentice_id IS NOT NULL AND apprentice_id ~ '^A\d{3}$' 
        THEN apprentice_id 
      ELSE NULL 
    END AS apprentice_id_validated,

    -- Gender cleaning and validation
    LOWER(TRIM(gender)) AS gender_raw,
    CASE 
      WHEN LOWER(TRIM(gender)) IN ('male', 'female', 'nonbinary', 'trans', 'other') 
        THEN LOWER(TRIM(gender)) 
      ELSE 'unknown' 
    END AS gender_validated,

    age,

    -- Ethnicity validation
    LOWER(TRIM(ethnicity)) AS ethnicity_raw,
    CASE 
      WHEN LOWER(TRIM(ethnicity)) IN ('black', 'asian', 'mixed', 'other') 
        THEN LOWER(TRIM(ethnicity)) 
      ELSE 'unknown' 
    END AS ethnicity_validated,

    -- SES
    LOWER(TRIM(socioeconomic_status)) AS ses_raw,
    CASE 
      WHEN LOWER(TRIM(socioeconomic_status)) IN ('underserved', 'not underserved') 
        THEN LOWER(TRIM(socioeconomic_status)) 
      ELSE 'unknown' 
    END AS ses_validated,

    -- ND flag
    LOWER(TRIM(neurodivergent_or_disabled)) AS nd_raw,
    CASE 
      WHEN LOWER(TRIM(neurodivergent_or_disabled)) IN ('yes', 'no') 
        THEN LOWER(TRIM(neurodivergent_or_disabled)) 
      ELSE 'unknown' 
    END AS nd_validated,

    INITCAP(TRIM(location)) || ', UK' AS location_cleaned,
    cohort_id
  FROM raw
)
SELECT * FROM cleaned
WHERE apprentice_id_validated IS NOT NULL;
