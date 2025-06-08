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


-- The final_success_risk_model SQL view generates a success_score for each apprentice by combining:

-- Engagement

-- Performance

-- Coach perception

-- Reliability

-- Each component is weighted, and all inputs are scaled to a 0–1 range for fairness and comparability.

-- Success Score Breakdown
-- Already between 0 and 1 (e.g., 0.87 for 87% attendance)

-- Weighted at 30% of total score

-- Scales the 1–5 feedback score down to 0–1

-- E.g., 4.0 becomes 0.8 → contributes 0.16

-- Weighted at 20%

-- Normalises the 0–100 project average

-- E.g., 75 becomes 0.75 → contributes 0.225

-- Weighted at 30%

-- Assumes 5 or fewer late submissions as the cap

-- The fewer the late submissions, the better

-- E.g., 2 lates → (5 - 2)/5 = 0.6 → contributes 0.12

-- Weighted at 20%