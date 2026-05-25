/*
=========================================================
Project: NYC Restaurant Health Inspection Analysis
File: 01_data_cleaning.sql
Purpose:
    Prepare the raw inspection data before analysis.

Main Cleaning Steps:
    1. Handle missing values
    2. Standardize cuisine names
    3. Clean date fields
    4. Validate cleaned data

Tables Used:
    restaurant_inspections_raw
=========================================================
*/





USE nyc_restaurant_inspection;
SET SQL_SAFE_UPDATES = 0;

/* =====================================================
   1. Handle Missing Values
===================================================== */

-- 1.1 Convert blank text values into NULL
UPDATE restaurant_inspections_raw
SET
    CAMIS = NULLIF(TRIM(CAMIS), ''),
    DBA = NULLIF(TRIM(DBA), ''),
    BORO = NULLIF(TRIM(BORO), ''),
    ZIPCODE = NULLIF(TRIM(ZIPCODE), ''),
    NTA = NULLIF(TRIM(NTA), ''),
    `CUISINE DESCRIPTION` = NULLIF(TRIM(`CUISINE DESCRIPTION`), ''),
    `INSPECTION DATE` = NULLIF(TRIM(`INSPECTION DATE`), ''),
    `GRADE DATE` = NULLIF(TRIM(`GRADE DATE`), ''),
    `INSPECTION TYPE` = NULLIF(TRIM(`INSPECTION TYPE`), ''),
    ACTION = NULLIF(TRIM(ACTION), ''),
    `VIOLATION CODE` = NULLIF(TRIM(`VIOLATION CODE`), ''),
    `VIOLATION DESCRIPTION` = NULLIF(TRIM(`VIOLATION DESCRIPTION`), ''),
    `CRITICAL FLAG` = NULLIF(TRIM(`CRITICAL FLAG`), ''),
    SCORE = NULLIF(TRIM(SCORE), ''),
    GRADE = NULLIF(TRIM(GRADE), '');


-- 1.2 Fill missing borough values
UPDATE restaurant_inspections_raw
SET BORO = 'Unknown'
WHERE BORO IS NULL
   OR BORO = '0';


-- 1.3 Fill missing neighborhood values
UPDATE restaurant_inspections_raw
SET NTA = 'Unknown'
WHERE NTA IS NULL;


-- 1.4 Fill missing cuisine values
UPDATE restaurant_inspections_raw
SET `CUISINE DESCRIPTION` = 'Unknown'
WHERE `CUISINE DESCRIPTION` IS NULL;


-- 1.5 Fill missing grade values
UPDATE restaurant_inspections_raw
SET GRADE = 'Not Graded'
WHERE GRADE IS NULL;


-- 1.6 Fill missing critical flag values
UPDATE restaurant_inspections_raw
SET `CRITICAL FLAG` = 'Not Applicable'
WHERE `CRITICAL FLAG` IS NULL;


-- 1.7 Fill missing action values
UPDATE restaurant_inspections_raw
SET ACTION = 'Unknown'
WHERE ACTION IS NULL;





/* =====================================================
   2. Standardize Cuisine Names
===================================================== */

-- 2.1 Standardize similar cuisine names
-- Keep this simple. Do not over-clean cuisine categories.
UPDATE restaurant_inspections_raw
SET `CUISINE DESCRIPTION` = 'Chinese'
WHERE `CUISINE DESCRIPTION` IN ('Asian/Chinese', 'Chinese');


UPDATE restaurant_inspections_raw
SET `CUISINE DESCRIPTION` = 'Asian/Asian Fusion'
WHERE `CUISINE DESCRIPTION` IN ('Asian', 'Asian/Asian Fusion');





/* =====================================================
   3. Clean Date Fields
===================================================== */

-- 3.1 Replace placeholder dates with NULL
UPDATE restaurant_inspections_raw
SET `INSPECTION DATE` = NULL
WHERE `INSPECTION DATE` = '01/01/1900';


UPDATE restaurant_inspections_raw
SET `GRADE DATE` = NULL
WHERE `GRADE DATE` = '01/01/1900';





/* =====================================================
   4. Quick Check
===================================================== */

-- 4.1 Check cleaned cuisine values
SELECT
    `CUISINE DESCRIPTION`,
    COUNT(*) AS row_count
FROM restaurant_inspections_raw
GROUP BY `CUISINE DESCRIPTION`
ORDER BY row_count DESC;


-- 4.2 Check cleaned grade values
SELECT
    GRADE,
    COUNT(*) AS row_count
FROM restaurant_inspections_raw
GROUP BY GRADE
ORDER BY row_count DESC;


-- 4.3 Check date range
SELECT
    MIN(STR_TO_DATE(`INSPECTION DATE`, '%m/%d/%Y')) AS earliest_inspection_date,
    MAX(STR_TO_DATE(`INSPECTION DATE`, '%m/%d/%Y')) AS latest_inspection_date
FROM restaurant_inspections_raw
WHERE `INSPECTION DATE` IS NOT NULL;


-- 4.4 Check critical flag values
SELECT
    `CRITICAL FLAG`,
    COUNT(*) AS row_count
FROM restaurant_inspections_raw
GROUP BY `CRITICAL FLAG`
ORDER BY row_count DESC;


-- 4.5 Check action values
SELECT
    ACTION,
    COUNT(*) AS row_count
FROM restaurant_inspections_raw
GROUP BY ACTION
ORDER BY row_count DESC;


SET SQL_SAFE_UPDATES = 1;


