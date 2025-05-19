@startuml
# Apprenticeship Success Tracker Star Schema
```plantuml
entity fact_apprentice_performance {
  * apprentice_id : TEXT <<FK>>
  * cohort_id : INT <<FK>>
  * attendance_rate : NUMERIC
  * feedback_score : NUMERIC
  * project_score_avg : NUMERIC
  * coach_visits : INT 
  * portal_logins: INT 
  * late_submissions : INT
  * placement_status : TEXT
  * is_successful : BOOLEAN
  * is_at_risk : BOOLEAN
  * curriculum_version : TEXT <<FK>>
  * perceived_readiness : TEXT 
}

entity dim_apprentice {
  * apprentice_id : TEXT
  --
  gender : TEXT
  age : INT
  ethnicity : TEXT
  socioeconomic_status : TEXT
  neurodivergent_or_disabled : TEXT
  location : TEXT
  cohort_id : INT <<FK>>
}

entity dim_cohort {
  * cohort_id : INT
  --
  cohort_name : TEXT
  start_date : DATE
  end_date : DATE
  curriculum_version : TEXT <<FK>>
}

entity dim_curriculum {
  * curriculum_version : TEXT
  --
  change_date : DATE
  change_type : TEXT
  description : TEXT
}
```

Relationships

fact_apprentice_performance -- dim_apprentice : apprentice_id
fact_apprentice_performance -- dim_cohort : cohort_id
fact_apprentice_performance -- dim_curriculum : curriculum_version
dim_cohort -- dim_curriculum : curriculum_version
@enduml
