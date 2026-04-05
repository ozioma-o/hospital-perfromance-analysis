# hospital-performance-analysis
# 🏥 Hospital Analytics Dashboard
**Tools:** SQL Server · Power BI · DAX · Power Query

A comprehensive end-to-end data analysis project on a hospital dataset covering patient behavior, financial performance, encounter patterns, and clinical procedures across an 11-year period (2011–2022).

---

## 📊 Dashboard Overview

| KPI | Value |
|-----|-------|
| Total Patients | 974 |
| Total Encounters | 28,891 |
| Average Claim Cost | $3.64K |
| Average Base Cost | $2.21K |
| Readmission Rate | 79% |
| Zero Payer Coverage | 13,586 encounters (47%) |

---

## 🗃️ Dataset
The dataset contains 5 interconnected tables:

| Table | Description |
|-------|-------------|
| **Patients** | 974 unique patient records with demographics |
| **Encounters** | 28,891 hospital visit records including costs and dates |
| **Procedures** | Medical procedures performed and their base costs |
| **Payers** | Insurance payer information |
| **Organization** | Hospital organization details |

---

## 🎯 Business Questions Answered

### 📈 Cost & Coverage Insights
- What are the top 10 procedures with the highest average base cost?
- What is the average total claim cost broken down by payer?
- How many encounters had zero payer coverage and what percentage does this represent?

### 🏥 Encounter Overview
- For each year, what percentage of encounters belonged to each encounter class?
- What percentage of encounters lasted over 24 hours versus under 24 hours?

### 👥 Patient Behavior Analysis
- How many unique patients were admitted each quarter over time?
- How many patients were readmitted within 30 days of a previous encounter?
- Which patients had the most readmissions?

---

## 🔍 Key Findings

- **ICU admissions** were the most expensive procedure at over **$200,000** average base cost
- **Medicaid** had the highest average claim cost among all payers, followed by uninsured patients
- **47% of encounters (13,586)** had zero payer coverage — a significant financial risk
- **Ambulatory** was the most common encounter class across all years
- **99.75%** of encounters lasted **under 24 hours** — consistent with the predominantly ambulatory visit pattern
- **Q1 2021** recorded the highest number of unique patient admissions
- Patient **Kimberly Collier** had the most readmissions at **1,375** — flagged for case management review
- The overall **readmission rate of 79%** indicates a critical area for quality of care improvement

---

## 🛠️ SQL Techniques Used

```sql
-- Self Join to find 30-day readmissions
SELECT 
    p.FIRST, p.LAST,
    COUNT(DISTINCT e2.ID) AS Readmissions,
    YEAR(e1.START) AS Year
FROM Encounters e1
INNER JOIN Encounters e2
    ON e1.PATIENT = e2.PATIENT
    AND e2.START > e1.STOP
    AND DATEDIFF(DAY, e1.STOP, e2.START) <= 30
    AND e1.ID != e2.ID
INNER JOIN Patients p ON e1.PATIENT = p.Id
GROUP BY p.FIRST, p.LAST, YEAR(e1.START)
ORDER BY Readmissions DESC;
```

```sql
-- Quarterly unique patient admissions
SELECT 
    YEAR(START) AS Year,
    DATEPART(QUARTER, START) AS Quarter,
    COUNT(DISTINCT PATIENT) AS UniquePatients
FROM Encounters
GROUP BY YEAR(START), DATEPART(QUARTER, START)
ORDER BY Year, Quarter;
```

```sql
-- Top 10 procedures by average base cost
SELECT TOP 10 
    DESCRIPTION,
    COUNT(DESCRIPTION) AS Frequency,
    AVG(BASECOST) AS AvgBaseCost
FROM Procedures
GROUP BY DESCRIPTION
ORDER BY AVG(BASECOST) DESC;
```

**SQL concepts applied:**
- Multi-table INNER JOINs
- Self JOINs for readmission logic
- DATEDIFF and DATEPART date functions
- COUNT DISTINCT for unique patient counting
- Aggregate functions (AVG, COUNT)
- TOP N filtering and ORDER BY ranking
- GROUP BY for data aggregation
- YEAR() extraction from datetime columns

---

## 📉 Power BI Visuals

| Visual | Chart Type | Insight |
|--------|-----------|---------|
| Encounter Class Distribution | Stacked Bar Chart | Ambulatory dominates across all years |
| Encounter Duration | Donut Chart | 99.75% lasted under 24 hours |
| Zero Payer Coverage | Card Visual | 13,586 encounters with no coverage |
| Top 10 Procedures by Base Cost |Stacked Bar Chart | ICU leads at $200,000+ |
| Avg Claim Cost by Payer | Bar Chart | Medicaid has highest claim costs |
| Quarterly Patient Admissions | Line Chart | Q1 2021 peak admissions |
| Most Readmitted Patients | Stacked Bar Chart | Kimberly Collier leads with 1,375 readmissions |

---

## ⚠️ Known Limitations

- **Patient name encoding:** Some patient names with special characters display incorrectly due to VARCHAR encoding issues in the original dataset
- **Readmissions slicer:** The Most Readmitted Patients chart displays overall totals rather than year-filtered results due to relationship complexity

---

## 💡 Recommendations

1. Review the **47% zero payer coverage** encounters — a major financial risk area
2. Investigate the **80% readmission rate** and implement improved discharge planning
3. Conduct a **case management review** for patient Kimberly Collier (1,375 readmissions)
4. Explore **cost reduction strategies** for ICU admissions averaging $200,000+


---

*Part of my Data Analytics Portfolio → [View All Projects](https://github.com/ozioma-o)*

