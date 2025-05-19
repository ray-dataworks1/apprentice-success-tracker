-- This SQL script serves as the cleaned stage table for the apprentice data.
-- It selects relevant columns from the dimension table dim_apprentice.

CREATE OR REPLACE VIEW stg_apprentice_data AS
SELECT
  apprentice_id,
  gender,
  age,
  ethnicity,
  socioeconomic_status,
  neurodivergent_or_disabled,
  location,
  cohort_id
FROM dim_apprentice;
