-- This produces a final quantitative success score between 0–1
-- models/final/final_success_risk_model.sql

CREATE OR REPLACE VIEW final_success_risk_model AS
SELECT
  apprentice_id,
  gender,
  ethnicity,
  socioeconomic_status,
  neurodivergent_or_disabled,
  location,
  curriculum_version,

  attendance_rate,
  feedback_score,
  project_score_avg,
  late_submissions,
  coach_visits,
  portal_logins,

  is_at_risk,
  is_successful,
  perceived_readiness,
  placement_status,

  -- Custom scoring logic
  ROUND(
  (
    -- Engagement
    (attendance_rate * 0.3) +

    -- Coach feedback
    (feedback_score / 5.0 * 0.2) +

    -- Project performance
    (project_score_avg / 100.0 * 0.3) +

    -- Submission reliability
    ((5 - GREATEST(late_submissions, 0)) / 5.0 * 0.2)
  )::NUMERIC, 2
) AS success_score
FROM int_apprentice_metrics;
