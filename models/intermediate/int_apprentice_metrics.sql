-- This SQL script serves as an intermediate table for the apprentice performance data.
-- It selects relevant columns from the fact_apprentice_performance table, stg_apprentice_data table, and dim_cohort table

CREATE OR REPLACE VIEW int_apprentice_metrics AS
SELECT
  s.apprentice_id,
  s.gender,
  s.ethnicity,
  s.socioeconomic_status,
  s.neurodivergent_or_disabled,
  s.location,
  c.curriculum_version,
  f.attendance_rate,
  f.feedback_score,
  f.project_score_avg,
  f.late_submissions,
  f.coach_visits,
  f.portal_logins,
  f.is_at_risk,
  f.is_successful,
  f.perceived_readiness,
  f.placement_status
FROM stg_apprentice_data s
JOIN fact_apprentice_performance f ON s.apprentice_id = f.apprentice_id
JOIN dim_cohort c ON s.cohort_id = c.cohort_id;
