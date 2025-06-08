CREATE OR REPLACE VIEW vw_success_predictors AS
SELECT
  gender,
  ethnicity,
  socioeconomic_status,
  neurodivergent_or_disabled,
  COUNT(*) AS total_apprentices,
  ROUND(AVG(CASE WHEN fp.placement_status = 'Placed' THEN 1 ELSE 0 END)::NUMERIC, 2) AS placement_rate,
  ROUND(AVG(CASE WHEN fp.is_successful THEN 1 ELSE 0 END)::NUMERIC, 2) AS success_rate,
  ROUND(AVG(attendance_rate)::NUMERIC, 2) AS avg_attendance,
  ROUND(AVG(feedback_score)::NUMERIC, 2) AS avg_feedback,
  ROUND(AVG(project_score_avg)::NUMERIC, 2) AS avg_project_score
FROM fact_apprentice_performance fp
JOIN dim_apprentice da ON fp.apprentice_id = da.apprentice_id
GROUP BY gender, ethnicity, socioeconomic_status, neurodivergent_or_disabled
ORDER BY placement_rate DESC;
