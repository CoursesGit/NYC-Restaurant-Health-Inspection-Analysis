/*
=========================================================
Project: NYC Restaurant Health Inspection Analysis
File: 02_exploratory_analysis.sql
Purpose:
    Answer the core analysis questions using SQL.

Main Sections:
    1. Create inspection-level view
    2. Overall Insights
    3. Violation Analysis
    4. Cuisine Analysis

Tables Used:
    restaurant_inspections_raw
=========================================================
*/





USE nyc_restaurant_inspection;

/* =====================================================
   1. Create Inspection-Level View
===================================================== */

-- The raw table is violation-record level.
-- One inspection can have multiple violation rows.
-- This view helps avoid double-counting inspections.

DROP VIEW IF EXISTS v_inspection_level;

CREATE VIEW v_inspection_level AS
SELECT DISTINCT
    CAMIS,
    DBA,
    BORO,
    ZIPCODE,
    NTA,
    `CUISINE DESCRIPTION`,
    `INSPECTION DATE`,
    `INSPECTION TYPE`,
    ACTION,
    SCORE,
    GRADE
FROM restaurant_inspections_raw
WHERE `INSPECTION DATE` IS NOT NULL;





/* =====================================================
   2. Overall Insights
===================================================== */

-- 2.1 Count total inspections by borough
SELECT
    BORO,
    COUNT(*) AS total_inspections
FROM v_inspection_level
WHERE BORO <> 'Unknown'
GROUP BY BORO
ORDER BY total_inspections DESC;


-- 2.2 Grade distribution across NYC
SELECT
    GRADE,
    COUNT(*) AS total_inspections
FROM v_inspection_level
WHERE GRADE IN ('A', 'B', 'C')
GROUP BY GRADE
ORDER BY total_inspections DESC;


-- 2.3 Most common inspection types
SELECT
    `INSPECTION TYPE`,
    COUNT(*) AS total_inspections
FROM v_inspection_level
WHERE `INSPECTION TYPE` IS NOT NULL
GROUP BY `INSPECTION TYPE`
ORDER BY total_inspections DESC
LIMIT 10;





/* =====================================================
   3. Violation Analysis
===================================================== */

-- 3.1 Top 10 most frequent violations
SELECT
    `VIOLATION CODE`,
    `VIOLATION DESCRIPTION`,
    COUNT(*) AS violation_count
FROM restaurant_inspections_raw
WHERE `VIOLATION CODE` IS NOT NULL
GROUP BY
    `VIOLATION CODE`,
    `VIOLATION DESCRIPTION`
ORDER BY violation_count DESC
LIMIT 10;


-- 3.2 Compare critical vs non-critical violations
SELECT
    `CRITICAL FLAG`,
    COUNT(*) AS violation_count
FROM restaurant_inspections_raw
WHERE `VIOLATION CODE` IS NOT NULL
  AND `CRITICAL FLAG` IN ('Critical', 'Not Critical')
GROUP BY `CRITICAL FLAG`
ORDER BY violation_count DESC;


-- 3.3 Boroughs with the highest critical violation rate
SELECT
    BORO,
    COUNT(*) AS total_violation_records,
    SUM(CASE WHEN `CRITICAL FLAG` = 'Critical' THEN 1 ELSE 0 END) AS critical_violations,
    ROUND(SUM(CASE WHEN `CRITICAL FLAG` = 'Critical' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS critical_violation_rate
FROM restaurant_inspections_raw
WHERE `VIOLATION CODE` IS NOT NULL
  AND `CRITICAL FLAG` IN ('Critical', 'Not Critical')
  AND BORO <> 'Unknown'
GROUP BY BORO
ORDER BY critical_violation_rate DESC;





/* =====================================================
   4. Cuisine Analysis
===================================================== */

-- 4.1 Compare grades by cuisine type
SELECT
    `CUISINE DESCRIPTION`,
    GRADE,
    COUNT(*) AS total_inspections
FROM v_inspection_level
WHERE `CUISINE DESCRIPTION` <> 'Unknown' AND GRADE IN ('A', 'B', 'C')
GROUP BY
    `CUISINE DESCRIPTION`,
    GRADE
ORDER BY
    `CUISINE DESCRIPTION`,
    total_inspections DESC;


-- 4.2 Top 5 cuisines with the lowest average scores
-- Lower scores mean better inspection results.
SELECT
    `CUISINE DESCRIPTION`,
    COUNT(*) AS total_inspections,
    ROUND(AVG(CAST(SCORE AS UNSIGNED)), 2) AS avg_score
FROM v_inspection_level
WHERE `CUISINE DESCRIPTION` <> 'Unknown' AND SCORE IS NOT NULL
GROUP BY `CUISINE DESCRIPTION`
ORDER BY avg_score ASC
LIMIT 5;


-- 4.3 Cuisines with the highest proportion of critical violations
SELECT
    `CUISINE DESCRIPTION`,
    COUNT(*) AS total_violation_records,
    SUM(CASE WHEN `CRITICAL FLAG` = 'Critical' THEN 1 ELSE 0 END) AS critical_violations,
    ROUND(SUM(CASE WHEN `CRITICAL FLAG` = 'Critical' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS critical_violation_rate
FROM restaurant_inspections_raw
WHERE `VIOLATION CODE` IS NOT NULL
  AND `CUISINE DESCRIPTION` <> 'Unknown'
  AND `CRITICAL FLAG` IN ('Critical', 'Not Critical')
GROUP BY `CUISINE DESCRIPTION`
ORDER BY critical_violation_rate DESC
LIMIT 5;






























