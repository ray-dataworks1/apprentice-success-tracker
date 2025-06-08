-- ========================================
-- MOCK DATA GENERATOR: Apprentice Success Tracker
-- ========================================



-- Step 1: dim_curriculum
DROP TABLE IF EXISTS dim_curriculum;
CREATE TABLE dim_curriculum (
    curriculum_version TEXT PRIMARY KEY,
    change_date DATE,
    change_type TEXT,
    description TEXT
);

INSERT INTO dim_curriculum VALUES
    ('V1', DATE '2023-09-01', 'Initial Launch', 'Original assessment-heavy format'),
    ('V2', DATE '2023-12-01', 'Format Revamp', 'Added project-based assessments'),
    ('V3', DATE '2024-03-01', 'Content Overhaul', 'Emphasized real-world readiness');

-- Step 2: dim_cohort
DROP TABLE IF EXISTS dim_cohort;
CREATE TABLE dim_cohort (
    cohort_id SERIAL PRIMARY KEY,
    cohort_name TEXT,
    start_date DATE,
    end_date DATE,
    curriculum_version TEXT REFERENCES dim_curriculum(curriculum_version)
);

INSERT INTO dim_cohort (cohort_name, start_date, end_date, curriculum_version) VALUES
    ('Autumn 2023', DATE '2023-09-01', DATE '2024-08-31', 'V1'),
    ('Winter 2023', DATE '2023-12-01', DATE '2024-11-30', 'V2'),
    ('Spring 2024', DATE '2024-03-01', DATE '2025-02-28', 'V3'); 

-- Step 3: dim_apprentice
DROP TABLE IF EXISTS dim_apprentice;
CREATE TABLE dim_apprentice (
    apprentice_id TEXT PRIMARY KEY,
    gender TEXT,
    age INT,
    ethnicity TEXT,
    socioeconomic_status TEXT,
    location TEXT,
    cohort_id INT REFERENCES dim_cohort(cohort_id)
);
-- Set the random seed for reproducibility
-- Note: This is a PostgreSQL-specific function. For other databases, you may need to set the seed differently.
SELECT setseed(0.42);

-- Generate and insert synthetic apprentice data
WITH numbers AS (
    SELECT generate_series(1, 60) AS n
),
random_values AS (
    SELECT 
        n,
        RANDOM() AS rand_gender,
        RANDOM() AS rand_ethnicity,
        RANDOM() AS rand_ses,
        RANDOM() AS rand_neuro
    FROM numbers
)
INSERT INTO dim_apprentice (
    apprentice_id, gender, age, ethnicity, 
    socioeconomic_status, neurodivergent_or_disabled, 
    location, cohort_id
)
SELECT 
    'A' || LPAD(n::text, 3, '0') AS apprentice_id,

    CASE 
        WHEN rand_gender < 0.55 THEN 'Female'
        WHEN rand_gender < 0.98 THEN 'Male'
        ELSE 'Other'
    END AS gender,

    (RANDOM() * 10 + 20)::INT AS age,

    CASE
        WHEN rand_ethnicity < 0.28 THEN 'Asian'
        WHEN rand_ethnicity < 0.42 THEN 'Black'
        WHEN rand_ethnicity < 0.52 THEN 'Mixed'
        WHEN rand_ethnicity < 0.58 THEN 'Other'
        ELSE 'White'
    END AS ethnicity,

    CASE
        WHEN rand_ses < 0.37 THEN 'Underserved'
        ELSE 'Not Underserved'
    END AS socioeconomic_status,

    CASE
        WHEN rand_neuro < 0.22 THEN 'Yes'
        ELSE 'No'
    END AS neurodivergent_or_disabled,

    CASE
        WHEN n % 3 = 0 THEN 'London'
        WHEN n % 3 = 1 THEN 'Manchester'
        ELSE 'Birmingham'
    END AS location,

    ((n - 1) / 20 + 1) AS cohort_id

FROM random_values;


-- Step 4: fact_apprentice_performance
-- Ensure reproducibility
SELECT setseed(0.42);

-- Create the fact table for apprentice performance
-- This table will store performance metrics for each apprentice
DROP TABLE IF EXISTS fact_apprentice_performance;
CREATE TABLE fact_apprentice_performance (
    apprentice_id TEXT PRIMARY KEY REFERENCES dim_apprentice(apprentice_id),
    cohort_id INT NOT NULL REFERENCES dim_cohort(cohort_id),
    curriculum_version TEXT NOT NULL REFERENCES dim_curriculum(curriculum_version),

    attendance_rate NUMERIC(3,2) CHECK (attendance_rate BETWEEN 0 AND 1),
    project_score_avg NUMERIC(4,1) CHECK (project_score_avg BETWEEN 0 AND 100),
    feedback_score NUMERIC(2,1) CHECK (feedback_score BETWEEN 1 AND 5),

    coach_visits INT CHECK (coach_visits >= 0),
    portal_logins INT CHECK (portal_logins >= 0),
    late_submissions INT CHECK (late_submissions >= 0),

    is_at_risk BOOLEAN NOT NULL,
    is_successful BOOLEAN NOT NULL,

    placement_status TEXT CHECK (placement_status IN ('Placed', 'Unplaced')),
    perceived_readiness TEXT CHECK (perceived_readiness IN ('Excellent', 'Good', 'Needs Support'))
);

-- Seeded, bias-aware performance pipeline
WITH apprentice_base AS (
    SELECT 
        a.apprentice_id,
        a.cohort_id,
        c.curriculum_version,
        a.neurodivergent_or_disabled,
        a.socioeconomic_status,
        a.gender,
        a.ethnicity,
        a.location
    FROM dim_apprentice a
    JOIN dim_cohort c ON a.cohort_id = c.cohort_id
),
metrics AS (
    SELECT
        apprentice_id,
        cohort_id,
        curriculum_version,
        neurodivergent_or_disabled,
        socioeconomic_status,
        gender,
        ethnicity,
        location,

        -- Clamped attendance rate to avoid >1.00 errors
        LEAST(1.00, (
            CASE 
                WHEN curriculum_version = 'V3' THEN (RANDOM() * 0.3 + 0.55)
                WHEN neurodivergent_or_disabled = 'Yes' THEN (RANDOM() * 0.3 + 0.6)
                WHEN gender = 'Female' THEN (RANDOM() * 0.3 + 0.7)
                ELSE (RANDOM() * 0.4 + 0.65)
            END
        ))::NUMERIC(3,2) AS attendance_rate,

        -- Scores + feedback
        CASE 
            WHEN curriculum_version = 'V3' THEN (RANDOM() * 20 + 60)
            WHEN neurodivergent_or_disabled = 'Yes' THEN (RANDOM() * 20 + 62)
            ELSE (RANDOM() * 25 + 65)
        END::NUMERIC(4,1) AS project_score_avg,

        CASE 
            WHEN curriculum_version = 'V3' THEN (RANDOM() * 1.5 + 2.5)
            WHEN neurodivergent_or_disabled = 'Yes' THEN (RANDOM() * 1.5 + 2.5)
            ELSE (RANDOM() * 2 + 3)
        END::NUMERIC(2,1) AS feedback_score,

        -- Support + engagement metrics
        CASE 
            WHEN neurodivergent_or_disabled = 'Yes' AND location = 'London' THEN (RANDOM() * 3 + 7)
            WHEN neurodivergent_or_disabled = 'Yes' THEN (RANDOM() * 4 + 5)
            ELSE (RANDOM() * 4 + 3)
        END::INT AS coach_visits,

        CASE 
            WHEN socioeconomic_status = 'Underserved' THEN (RANDOM() * 50 + 20)
            ELSE (RANDOM() * 70 + 30)
        END::INT AS portal_logins,

        CASE 
            WHEN neurodivergent_or_disabled = 'Yes' AND socioeconomic_status = 'Underserved' THEN (RANDOM() * 3 + 2)
            ELSE (RANDOM() * 3)::INT
        END::INT AS late_submissions
    FROM apprentice_base
),
flags AS (
    SELECT *,
        CASE 
            WHEN attendance_rate < 0.7 OR feedback_score < 3 THEN TRUE 
            ELSE FALSE 
        END AS is_at_risk,

        CASE 
            WHEN attendance_rate >= 0.7 AND feedback_score >= 3 THEN TRUE 
            ELSE FALSE 
        END AS is_successful,

        CASE 
            WHEN project_score_avg >= 85 AND feedback_score >= 4.5 THEN 'Excellent'
            WHEN project_score_avg >= 70 THEN 'Good'
            ELSE 'Needs Support'
        END AS perceived_readiness
    FROM metrics
),
final_flags AS (
    SELECT *,
        CASE 
            WHEN is_at_risk
              AND neurodivergent_or_disabled = 'Yes'
              AND socioeconomic_status = 'Underserved'
              AND RANDOM() < 0.85 THEN 'Unplaced'

            WHEN perceived_readiness = 'Excellent' AND RANDOM() < 0.95 THEN 'Placed'
            WHEN perceived_readiness = 'Good' AND RANDOM() < 0.8 THEN 'Placed'
            WHEN perceived_readiness = 'Needs Support' AND RANDOM() < 0.3 THEN 'Placed'
            ELSE 'Unplaced'
        END AS placement_status
    FROM flags
)

-- Final insert
INSERT INTO fact_apprentice_performance (
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
)
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
FROM final_flags;




-- OVERVIEW
-- This script creates a **synthetic dataset** to simulate apprentice performance across cohorts and curricula. It's ideal for Analytics Engineering and DE use cases involving pipeline testing, fairness logic, or BI dashboard development. Data generation is **bias-aware** and seeded for **reproducibility**.

-- ===========================================
-- STEP 1: dim_curriculum — Curriculum Versions
-- -------------------------------------------
-- This table tracks curriculum changes over time.
-- Each version (V1–V3) includes:
-- - `change_date`: When the update occurred
-- - `change_type`: A short label for the update (e.g. Format Revamp)
-- - `description`: Context about what changed (e.g. more project-based work)

-- ===========================================
-- STEP 2: dim_cohort — Apprentice Cohorts
-- -------------------------------------------
-- Each cohort has:
-- - A name and date range (e.g. 'Winter 2023')
-- - A linked `curriculum_version` (FK from `dim_curriculum`)
-- This allows curriculum shifts to be tied to actual learner groups.

-- ===========================================
-- STEP 3: dim_apprentice — Synthetic Apprentice Demographics
-- -------------------------------------------
-- - 60 apprentices are generated using `generate_series`.
-- - Random seed `0.42` ensures **repeatable outputs**.
-- - Each apprentice gets:
--   - ID (e.g., 'A001')
--   - Gender: 55% Female, 43% Male, 2% Other
--   - Age: 20–30
--   - Ethnicity: Weighted across 5 groups
--   - Socioeconomic Status: 37% marked 'Underserved'
--   - Neurodivergence/Disability: 22% marked 'Yes'
--   - Location: Rotates between London, Manchester, Birmingham
--   - Cohort ID: Apprentices divided evenly into 3 cohorts

-- ===========================================
--  STEP 4: fact_apprentice_performance — Core Metrics Table
-- -------------------------------------------
-- This fact table stores **key success indicators** per apprentice.

-- Core fields:
-- - Attendance rate (0–1.00)
-- - Average project score (0–100)
-- - Feedback score (1.0–5.0)
-- - Coach visits, portal logins, late submissions
-- - Flags: `is_at_risk`, `is_successful`
-- - Outcomes: `placement_status`, `perceived_readiness`

-- Data generation uses 3 CTE layers:

-- -- apprentice_base:
-- Joins each apprentice to their cohort and curriculum, retaining demographics for logic control.

-- -- metrics:
-- Applies conditional logic to generate performance data.
-- Bias-aware tweaks include:
--   - Lower attendance for V3 or neurodivergent groups
--   - Higher attendance for female apprentices
--   - Higher coach visits for neurodivergent apprentices in London
--   - Fewer portal logins if underserved
--   - More late submissions if both ND + underserved

-- -- flags:
-- Calculates derived metrics:
--   - `is_at_risk`: <70% attendance OR feedback <3
--   - `is_successful`: ≥70% AND feedback ≥3
--   - `perceived_readiness`: Tiered as 'Excellent', 'Good', or 'Needs Support' based on project and feedback scores

-- -- final_flags:
-- Assigns `placement_status` based on realistic bias-aware probabilities:
--   - ND + Underserved + At Risk: 85% chance of Unplaced
--   - Excellent: 95% Placed
--   - Good: 80% Placed
--   - Needs Support: 30% Placed
--   - Others: Default Unplaced

-- Final INSERT:
-- Data from `final_flags` is inserted into the `fact_apprentice_performance` table.

-- ===========================================
-- USE CASES
-- -------------------------------------------
-- - Test dashboards, ETL pipelines, or BI tools
-- - Validate fairness logic and outcome disparities
-- - Run simulations on apprentice outcomes and curriculum effectiveness