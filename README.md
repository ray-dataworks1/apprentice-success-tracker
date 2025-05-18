<h1 align="center">Apprentice Success Tracker</h1>
<p align="center"><a href="#project-description">Project Description</a> - <a href="#key-features">Key Features</a> - <a href="#technology-stack">Tech Stack</a></p>

## Project Description

The Apprentice Success Tracker is a stakeholder-facing analytics project designed to identify the key predictors of apprenticeship success and flag individuals at risk of not securing placement. Built using realistic mock data modelled on Multiverse’s mission of equitable talent development, the project helps program managers prioritize interventions, understand cohort trends, and monitor curriculum impact over time.

## Key Components

dim\_apprentice – Stores apprentice demographics (gender, ethnicity, socioeconomic status, etc.)

dim\_cohort – Defines cohort groupings and their curriculum version

dim\_curriculum – Tracks curriculum change history with descriptions for auditability

fact\_ apprentice\_performance – Central fact table combining engagement and performance metrics

SQL Logic Layer – Includes staging, intermediate, and final models to structure and clean the data

Stakeholder Story – A concise narrative that translates insights into meaningful business actions

Dashboard Layer – Power BI/Excel compatible output for stakeholder visibility

## Key Features

Risk Flagging – Automatically flags apprentices at risk using logic based on attendance, feedback, and behaviour

Behaviourally-Informed Logic – Combines quantitative performance with qualitative equity insight

Cohort & Curriculum Impact Analysis – Tracks trends over time and measures outcomes across curriculum changes

Modular SQL Design – Clean, maintainable queries following dbt-style best practices

Realistic Mock Data – Synthesised using statistical and sociological assumptions from real-world apprenticeships

Stakeholder-Ready Insights – Output designed for coaching, curriculum planning, and program improvement

Privacy-Conscious – No names or PII; fully anonymised apprentice data aligned with ethical data handling

## Tech Stack

PostgreSQL – Used for mock data generation, modelling, and querying

dbt-Inspired Folder Structure – Models split into staging, intermediate, and final layers

GitHub – Version-controlled and structured for extensibility

Power BI – Dashboard layer for stakeholder delivery

Behavioural Science + Equity Lens – Used to frame risk logic and stakeholder relevance
