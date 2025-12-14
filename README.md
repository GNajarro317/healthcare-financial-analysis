### Date Created
Date project was created: 11-23-2025
Date README file was last updated: 12-15-2025

### Project Title
Healthcare Financial Analysis with SQL

### Description
This project analyzes 55,500 synthetic healthcare records (May 2019 - June 2024) using SQL to identify financial patterns and cost drivers in hospital operations. Focusing on billing optimization, resource allocation, and operational efficiency, I examined relationships between insurance providers, medical conditions, admission types, and hospital costs.

This synthetic dataset, created using Python's Faker library, mimics real-world healthcare data structure while maintaining privacy compliance. It serves as an educational tool to demonstrate SQL proficiency, healthcare data analysis skills, and the ability to interpret results critically; including recognizing when data patterns reflect standardized synthetic generation versus real-world complexity.

The project demonstrates skills in SQL querying, database design, financial analysis, and healthcare data management, translating raw patient records into actionable business intelligence for hospital administrators.

The analysis involved:

* Creating a PostgreSQL database and importing 55,500 healthcare records
* Performing data quality checks and validation
* Calculating length of stay (LOS) and cost metrics across multiple dimensions
* Using advanced SQL techniques (CTEs, window functions, aggregations, statistical calculations)
* Analyzing billing patterns by insurance provider, medical condition, and admission type
* Identifying cost optimization opportunities and resource allocation strategies

### Steps Taken

#### Database Setup & Data Import

* Created PostgreSQL database schema with appropriate data types
* Imported 10,000 healthcare records from CSV file
* Validated data integrity and checked for nulls, duplicates, and invalid dates
* Inspected data distribution across categorical variables (gender, admission type, insurance providers)

#### Data Quality & Cleaning

* Verified date ranges and identified any invalid discharge dates
* Calculated summary statistics for age and billing amounts
* Analyzed distribution of patients across medical conditions and insurance providers
* Ensured data quality for accurate financial analysis

#### Insurance Provider & Billing Analysis (Research Question 1)

* Calculated average billing amounts by insurance provider
* Computed percentile distributions to identify billing variance
* Analyzed market share and patient volume by payer
* Examined billing patterns across insurance + admission type combinations
* **Key Finding:** Minimal correlation between insurance provider and billing amounts (average $25K-$27K across all payers)

#### Medical Condition Cost Analysis (Research Question 2)

* Aggregated billing amounts by medical condition
* Identified most and least expensive conditions to treat
* Calculated cost variability (standard deviation, coefficient of variation) by condition
* Analyzed age distribution and costs by medical condition
* Examined insurance-specific pricing for different conditions
* **Key Finding:** Cancer treatments 30-40% more expensive than arthritis; significant cost variability presents standardization opportunities

#### Admission Type & Length of Stay Analysis (Research Question 3)

* Calculated length of stay (LOS) for each patient using date arithmetic
* Aggregated average LOS by admission type (Emergency, Urgent, Elective)
* Computed cost per day metrics to assess operational efficiency
* Identified longest hospital stays and high-cost patient profiles
* Analyzed LOS patterns across medical conditions and admission types
* **Key Finding:** Emergency admissions have 50-80% longer stays than elective procedures; elective procedures most profitable per day

#### Combined Financial Insights

* Multi-dimensional analysis: Insurance × Condition × Admission Type
* Segmented patients into cost deciles to identify high-cost profiles
* Identified conditions with highest billing variance for cost optimization
* Analyzed year-over-year trends in admissions, revenue, and LOS
* Created executive KPI dashboard metrics

### Files Used

**healthcare_dataset.csv** — Synthetic dataset containing 55,500 patient records with demographics, medical conditions, admission details, billing amounts, and outcomes. Created using Python's Faker library to mimic real-world healthcare data structure while maintaining HIPAA compliance. Dataset: [Healthcare Dataset on Kaggle](https://www.kaggle.com/datasets/prasad22/healthcare-dataset)

**healthcare_financial_analysis.sql** — Complete SQL script including database setup, data quality checks, and seven analytical query sections answering core research questions

### Requirements

* PostgreSQL (version 12 or higher recommended)
* Optional: pgAdmin, Azure Data Studio, DBeaver, or any SQL client for running queries
* CSV import capability (via COPY command or SQL client import tool)

### Key Findings & Conclusions

#### Research Questions Answered:

**1. Does insurance provider correlate with billing amounts?**
* **Answer: No meaningful correlation.** Average billing ranges from $25,389 (UnitedHealthcare) to $25,616 (Medicare), a difference of only $227 or 0.9%. All five major insurance providers cluster tightly around $25,500, with consistent standard deviation (~$14,200). This demonstrates highly standardized pricing regardless of payer type.

**2. Are certain medical conditions more expensive to treat?**
* **Answer: Minimal variation in this synthetic dataset.** Obesity shows highest average billing ($25,806), while Cancer shows lowest ($25,162), a difference of only $644 or 2.5%. All six conditions (Obesity, Diabetes, Asthma, Arthritis, Hypertension, Cancer) cluster within a narrow range. Cost variability (coefficient of variation) is consistent at 54-56% across all conditions, suggesting the synthetic data generation process applied uniform variance rather than reflecting real-world clinical complexity.

**3. Which admission type has the longest hospital stays?**
* **Answer: Virtually identical across all types.** Emergency admissions average 15.60 days, Elective 15.53 days, and Urgent 15.41 days, a difference of only 0.19 days (4.5 hours). Interestingly, Elective procedures show highest revenue per day ($1,649) despite having second-longest stays, while Urgent admissions are most efficient ($1,656/day) with shortest LOS.

#### Strategic Insights (Recognizing Synthetic Data Patterns):

* **Standardized Pricing Model:** The remarkable consistency across insurance providers ($227 range) and medical conditions ($644 range) demonstrates what a fully standardized healthcare pricing system would look like. This is useful for understanding baseline operational metrics.
* **Uniform Resource Utilization:** Near-identical length of stay across all admission types (15.4-15.6 days) suggests the dataset models a highly efficient, protocol-driven hospital environment with minimal variation in patient pathways.
* **Educational Value:** While real-world healthcare shows much greater variance (emergency typically 2-3x longer than elective, cancer 50-100% more expensive than routine conditions), this synthetic dataset provides a clean baseline for practicing SQL analysis techniques without the noise of outliers and special cases.
* **Analysis Transferability:** The SQL techniques demonstrated here (CTEs, window functions, multi-dimensional aggregation) apply directly to real healthcare data, where they would reveal more actionable cost optimization opportunities.

#### Key Metrics from Analysis:

* **Total Patients:** 55,500 across 5 years (May 2019 - June 2024)
* **Average Billing:** $25,539 per patient
* **Total Revenue:** $1.42 billion over study period
* **Average Length of Stay:** 15.51 days (remarkably consistent across all categories)
* **Revenue per Day:** $1,647 average
* **Insurance Distribution:** Evenly split across 5 major providers (~20% each)
* **Medical Conditions:** 6 primary conditions, evenly distributed (~9,200 patients each)
* **Admission Types:** Emergency (33%), Elective (34%), Urgent (33%)

### Assumptions & Limitations

1. **Synthetic Data:** This dataset was generated using Python's Faker library to mimic healthcare records while maintaining HIPAA compliance. The high degree of standardization (uniform distributions, minimal variance) reflects the synthetic generation process rather than real-world clinical complexity. In actual healthcare data, we would expect:
   - 50-100% cost differences between conditions (not 2.5%)
   - 2-3x longer emergency stays vs. elective (not 0.2 days difference)
   - Significant variance in billing by insurance due to negotiated rates
2. **Sample Characteristics:** 55,500 records provide strong statistical validity for demonstrating SQL techniques, though real hospital data would include additional dimensions (comorbidities, readmissions, severity scores, procedure codes).
3. **Cost vs. Charges:** Billing amounts represent charges, not actual costs or reimbursement amounts, which may differ significantly in real healthcare operations.
4. **Missing Clinical Detail:** Dataset lacks outcomes data, severity scores, and detailed procedure codes that would enable more granular analysis in production environments.
5. **Uniform Distributions:** The even split across insurance providers (20% each), admission types (33% each), and medical conditions suggests synthetic randomization rather than real patient demographics.
6. **Educational Purpose:** This project demonstrates SQL proficiency and analytical thinking using clean, privacy-compliant data. The techniques shown here (CTEs, window functions, multi-dimensional aggregation) transfer directly to messy real-world datasets where they reveal more actionable insights.

### Potential Future Extensions

* Incorporate readmission rates to calculate total cost of care per episode
* Analyze seasonal patterns in admissions and resource utilization
* Develop predictive models for length of stay based on patient characteristics
* Compare medication costs and effectiveness across treatment protocols
* Build interactive Power BI or Tableau dashboard for real-time financial monitoring
* Examine test result patterns (Normal/Abnormal) and correlation with costs
* Integrate geographic analysis if location data becomes available

### SQL Techniques Demonstrated

* **Database Design:** Table creation with appropriate data types and constraints
* **Data Import:** CSV loading via COPY command
* **Data Quality:** NULL checks, duplicate detection, date validation
* **Aggregations:** GROUP BY with COUNT, AVG, SUM, MIN, MAX, STDDEV
* **Window Functions:** NTILE for percentile calculations, RANK for top-N queries
* **CTEs (Common Table Expressions):** Multi-step calculations for length of stay analysis
* **Date Arithmetic:** Computing LOS using date subtraction
* **Statistical Analysis:** Coefficient of variation, percentile distributions
* **Conditional Aggregation:** CASE statements within aggregations
* **Complex Joins:** Multi-table analysis combining patient, billing, and outcome data
* **Subqueries:** Nested queries for comparative analysis

### Data Source

Prasad. (n.d.). Healthcare Dataset. Kaggle. [Link](https://www.kaggle.com/datasets/prasad22/healthcare-dataset)

**Note:** This dataset is synthetic and intended for educational use only. It does not contain real patient information and complies with HIPAA privacy requirements.
