-- =====================================================================
-- Healthcare Financial Analysis
-- Author: Gerardo Najarro
-- Created: 11-23-2025
-- Description:
--     This SQL script creates a table, imports synthetic healthcare data,
--     and runs analytical queries exploring insurance billing patterns,
--     medical condition costs, and admission type resource utilization
--     to demonstrate SQL skills and financial analysis capabilities.
-- 
-- Research Questions:
-- 1. Does insurance provider correlate with billing amounts?
-- 2. Are certain medical conditions more expensive to treat?
-- 3. Which admission type has the longest hospital stays?
-- =====================================================================


-- ==========================================================
-- 1. CREATE TABLE
--    Schema for healthcare_dataset.csv
-- ==========================================================

DROP TABLE IF EXISTS healthcare_data;

CREATE TABLE healthcare_data (
    patient_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INTEGER,
    gender VARCHAR(10),
    blood_type VARCHAR(5),
    medical_condition VARCHAR(50),
    date_of_admission DATE,
    doctor VARCHAR(100),
    hospital VARCHAR(100),
    insurance_provider VARCHAR(50),
    billing_amount DECIMAL(10, 2),
    room_number INTEGER,
    admission_type VARCHAR(20),
    discharge_date DATE,
    medication VARCHAR(50),
    test_results VARCHAR(20)
);


-- ==========================================================
-- 2. IMPORT CSV
--    IMPORTANT: Update the file path below to your CSV location.
--    Example file path:
--    '/path/to/healthcare_dataset.csv'
-- ==========================================================

COPY healthcare_data(name, age, gender, blood_type, medical_condition, 
                     date_of_admission, doctor, hospital, insurance_provider,
                     billing_amount, room_number, admission_type, 
                     discharge_date, medication, test_results)
FROM 'C:\temp\healthcare_dataset.csv'
DELIMITER ','
CSV HEADER;


-- ==========================================================
-- 3. DATA QUALITY CHECKS
--    Verify import and validate data integrity
-- ==========================================================

-- Verify import
SELECT COUNT(*) AS total_records FROM healthcare_data;

-- Check for NULL values
SELECT 
    COUNT(*) AS total_records,
    COUNT(*) - COUNT(name) AS missing_names,
    COUNT(*) - COUNT(age) AS missing_ages,
    COUNT(*) - COUNT(medical_condition) AS missing_conditions,
    COUNT(*) - COUNT(billing_amount) AS missing_billing,
    COUNT(*) - COUNT(insurance_provider) AS missing_insurance
FROM healthcare_data;

-- Validate date ranges
SELECT 
    MIN(date_of_admission) AS earliest_admission,
    MAX(date_of_admission) AS latest_admission,
    MIN(discharge_date) AS earliest_discharge,
    MAX(discharge_date) AS latest_discharge
FROM healthcare_data;

-- Summary statistics
SELECT 
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(age), 2) AS avg_age,
    MIN(billing_amount) AS min_billing,
    MAX(billing_amount) AS max_billing,
    ROUND(AVG(billing_amount), 2) AS avg_billing
FROM healthcare_data;


-- ==========================================================
-- 4. QUERIES
--    Analytical queries answering research questions
-- ==========================================================


-- ----------------------------------------------------------
-- Query 1
-- Average billing amount by insurance provider
-- Rationale: Test if insurance type affects billing amounts.
-- ----------------------------------------------------------
SELECT 
    insurance_provider,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(MIN(billing_amount), 2) AS min_billing,
    ROUND(MAX(billing_amount), 2) AS max_billing,
    ROUND(STDDEV(billing_amount), 2) AS std_dev_billing
FROM healthcare_data
GROUP BY insurance_provider
ORDER BY avg_billing DESC;


-- ----------------------------------------------------------
-- Query 2
-- Billing distribution by insurance provider (percentiles)
-- Rationale: Understand billing variance beyond simple averages.
-- ----------------------------------------------------------
WITH billing_percentiles AS (
    SELECT 
        insurance_provider,
        billing_amount,
        NTILE(4) OVER (PARTITION BY insurance_provider ORDER BY billing_amount) AS quartile
    FROM healthcare_data
)
SELECT 
    insurance_provider,
    MIN(CASE WHEN quartile = 1 THEN billing_amount END) AS percentile_25,
    MIN(CASE WHEN quartile = 2 THEN billing_amount END) AS percentile_50_median,
    MIN(CASE WHEN quartile = 3 THEN billing_amount END) AS percentile_75
FROM billing_percentiles
GROUP BY insurance_provider
ORDER BY percentile_50_median DESC;


-- ----------------------------------------------------------
-- Query 3
-- Top 10 most expensive insurance claims
-- Rationale: Identify outlier high-cost cases.
-- ----------------------------------------------------------
SELECT 
    name,
    insurance_provider,
    medical_condition,
    admission_type,
    billing_amount,
    RANK() OVER (ORDER BY billing_amount DESC) AS cost_rank
FROM healthcare_data
ORDER BY billing_amount DESC
LIMIT 10;


-- ----------------------------------------------------------
-- Query 4
-- Insurance provider market share
-- Rationale: Understand payer distribution.
-- ----------------------------------------------------------
SELECT 
    insurance_provider,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM healthcare_data), 2) AS market_share_pct
FROM healthcare_data
GROUP BY insurance_provider
ORDER BY patient_count DESC;


-- ----------------------------------------------------------
-- Query 5
-- Average billing by medical condition
-- Rationale: Identify which conditions drive highest costs.
-- ----------------------------------------------------------
SELECT 
    medical_condition,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(MIN(billing_amount), 2) AS min_billing,
    ROUND(MAX(billing_amount), 2) AS max_billing,
    ROUND(STDDEV(billing_amount), 2) AS std_dev_billing
FROM healthcare_data
GROUP BY medical_condition
ORDER BY avg_billing DESC;


-- ----------------------------------------------------------
-- Query 6
-- Most/least expensive medical conditions (top 5 and bottom 5)
-- Rationale: Highlight cost extremes by condition.
-- ----------------------------------------------------------
WITH condition_costs AS (
    SELECT 
        medical_condition,
        ROUND(AVG(billing_amount), 2) AS avg_billing,
        COUNT(*) AS patient_count
    FROM healthcare_data
    GROUP BY medical_condition
)
(SELECT 'Most Expensive' AS category, * FROM condition_costs ORDER BY avg_billing DESC LIMIT 5)
UNION ALL
(SELECT 'Least Expensive' AS category, * FROM condition_costs ORDER BY avg_billing ASC LIMIT 5)
ORDER BY category DESC, avg_billing DESC;


-- ----------------------------------------------------------
-- Query 7
-- Medical conditions with highest cost variability
-- Rationale: Find conditions with inconsistent pricing (standardization opportunity).
-- ----------------------------------------------------------
SELECT 
    medical_condition,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(STDDEV(billing_amount), 2) AS std_dev,
    ROUND(STDDEV(billing_amount) / NULLIF(AVG(billing_amount),0) * 100, 2) AS coefficient_variation_pct
FROM healthcare_data
GROUP BY medical_condition
ORDER BY coefficient_variation_pct DESC
LIMIT 10;


-- ----------------------------------------------------------
-- Query 8
-- Average length of stay by admission type
-- Rationale: Determine which admission types consume most resources.
-- ----------------------------------------------------------
WITH length_of_stay AS (
    SELECT 
        *,
        discharge_date - date_of_admission AS los_days
    FROM healthcare_data
)
SELECT 
    admission_type,
    COUNT(*) AS patient_count,
    ROUND(AVG(los_days), 2) AS avg_los_days,
    MIN(los_days) AS min_los_days,
    MAX(los_days) AS max_los_days,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(AVG(billing_amount) / NULLIF(AVG(los_days), 0), 2) AS avg_cost_per_day
FROM length_of_stay
GROUP BY admission_type
ORDER BY avg_los_days DESC;


-- ----------------------------------------------------------
-- Query 9
-- Length of stay distribution by percentile
-- Rationale: Understand typical vs. extreme LOS by admission type.
-- ----------------------------------------------------------
WITH length_of_stay AS (
    SELECT 
        admission_type,
        discharge_date - date_of_admission AS los_days
    FROM healthcare_data
),
los_percentiles AS (
    SELECT 
        admission_type,
        los_days,
        NTILE(4) OVER (PARTITION BY admission_type ORDER BY los_days) AS quartile
    FROM length_of_stay
)
SELECT 
    admission_type,
    MIN(CASE WHEN quartile = 1 THEN los_days END) AS percentile_25,
    MIN(CASE WHEN quartile = 2 THEN los_days END) AS percentile_50_median,
    MIN(CASE WHEN quartile = 3 THEN los_days END) AS percentile_75,
    MAX(los_days) AS max_los
FROM los_percentiles
GROUP BY admission_type
ORDER BY percentile_50_median DESC;


-- ----------------------------------------------------------
-- Query 10
-- Longest hospital stays (top 20)
-- Rationale: Identify resource-intensive patients.
-- ----------------------------------------------------------
SELECT 
    name,
    admission_type,
    medical_condition,
    date_of_admission,
    discharge_date,
    discharge_date - date_of_admission AS los_days,
    billing_amount,
    ROUND(billing_amount / NULLIF(discharge_date - date_of_admission, 0), 2) AS cost_per_day
FROM healthcare_data
ORDER BY los_days DESC
LIMIT 20;


-- ----------------------------------------------------------
-- Query 11
-- Comprehensive cost analysis: Insurance + Condition + Admission Type
-- Rationale: Multi-dimensional view of cost drivers.
-- ----------------------------------------------------------
WITH length_of_stay AS (
    SELECT 
        *,
        discharge_date - date_of_admission AS los_days
    FROM healthcare_data
)
SELECT 
    insurance_provider,
    medical_condition,
    admission_type,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(AVG(los_days), 2) AS avg_los_days,
    ROUND(AVG(billing_amount) / NULLIF(AVG(los_days), 0), 2) AS avg_cost_per_day
FROM length_of_stay
GROUP BY insurance_provider, medical_condition, admission_type
HAVING COUNT(*) >= 5
ORDER BY avg_billing DESC
LIMIT 20;


-- ----------------------------------------------------------
-- Query 12
-- High-cost patient profiles (top decile analysis)
-- Rationale: Understand characteristics of most expensive patients.
-- ----------------------------------------------------------
WITH length_of_stay AS (
    SELECT 
        *,
        discharge_date - date_of_admission AS los_days
    FROM healthcare_data
),
patient_costs AS (
    SELECT 
        *,
        NTILE(10) OVER (ORDER BY billing_amount) AS cost_decile
    FROM length_of_stay
)
SELECT 
    cost_decile,
    COUNT(*) AS patient_count,
    ROUND(AVG(age), 1) AS avg_age,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(AVG(los_days), 2) AS avg_los_days,
    MODE() WITHIN GROUP (ORDER BY admission_type) AS most_common_admission_type,
    MODE() WITHIN GROUP (ORDER BY medical_condition) AS most_common_condition,
    MODE() WITHIN GROUP (ORDER BY insurance_provider) AS most_common_insurance
FROM patient_costs
GROUP BY cost_decile
ORDER BY cost_decile DESC;


-- ----------------------------------------------------------
-- Query 13
-- Financial summary by year
-- Rationale: Track trends over time.
-- ----------------------------------------------------------
SELECT 
    EXTRACT(YEAR FROM date_of_admission) AS admission_year,
    COUNT(*) AS total_admissions,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(SUM(billing_amount), 2) AS total_revenue,
    ROUND(AVG(discharge_date - date_of_admission), 2) AS avg_los_days
FROM healthcare_data
GROUP BY admission_year
ORDER BY admission_year;


-- ----------------------------------------------------------
-- Query 14
-- Overall hospital financial KPIs
-- Rationale: Executive summary metrics.
-- ----------------------------------------------------------
WITH length_of_stay AS (
    SELECT 
        *,
        discharge_date - date_of_admission AS los_days
    FROM healthcare_data
)
SELECT 
    COUNT(*) AS total_patients,
    ROUND(AVG(billing_amount), 2) AS avg_billing_per_patient,
    ROUND(SUM(billing_amount), 2) AS total_revenue,
    ROUND(AVG(los_days), 2) AS avg_length_of_stay,
    ROUND(AVG(billing_amount) / NULLIF(AVG(los_days), 0), 2) AS avg_revenue_per_day,
    COUNT(DISTINCT medical_condition) AS unique_conditions_treated,
    COUNT(DISTINCT insurance_provider) AS insurance_providers_accepted,
    COUNT(DISTINCT doctor) AS total_doctors
FROM length_of_stay;