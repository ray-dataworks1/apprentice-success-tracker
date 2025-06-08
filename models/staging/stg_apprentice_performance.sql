CREATE OR REPLACE VIEW stg_apprentice_performance AS
WITH raw AS (
  SELECT
    apprentice_id,
    cohort_id,
    curriculum_version,
    attendance_rate,
    project_score_avg,
    feedback_score,
    coach_visits,
    portal_logins,
    late_submissions,
    is_at_risk,
    is_successful,
    placement_status,
    perceived_readiness
  FROM fct_apprentice_performance
),
cleaned AS (
  SELECT
    apprentice_id,
    cohort_id,
    curriculum_version,

    CAST(attendance_rate AS FLOAT) AS attendance_rate,
    CAST(project_score_avg AS FLOAT) AS project_score_avg,
    CAST(feedback_score AS FLOAT) AS feedback_score,
    CAST(coach_visits AS INT) AS coach_visits,
    CAST(portal_logins AS INT) AS portal_logins,
    CAST(late_submissions AS INT) AS late_submissions,

    CAST(is_at_risk AS BOOLEAN) AS is_at_risk,
    CAST(is_successful AS BOOLEAN) AS is_successful,

    INITCAP(TRIM(placement_status)) AS placement_status_cleaned,
    INITCAP(TRIM(perceived_readiness)) AS perceived_readiness_cleaned
  FROM raw
)
SELECT *
FROM cleaned
WHERE apprentice_id IS NOT NULL
  AND curriculum_version ~ '^V\d$'
  AND cohort_id IS NOT NULL;
