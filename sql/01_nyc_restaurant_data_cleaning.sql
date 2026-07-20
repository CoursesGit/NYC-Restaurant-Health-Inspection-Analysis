-- NYC Restaurant Health Inspection Analysis
-- 保留原始表，通过 View 整理分析需要的数据

USE nyc_restaurant_inspection;





-- 1. 数据检查

-- 1.1 查看原始数据

DESCRIBE restaurant_inspections_raw;

SELECT *
FROM restaurant_inspections_raw
LIMIT 10;

SELECT COUNT(*) AS raw_row_count
FROM restaurant_inspections_raw;


-- 1.2 检查主要字段的空值
-- Grade、Score 和 Violation 为空不一定是数据错误

SELECT
    SUM(NULLIF(TRIM(CAMIS), '') IS NULL) AS missing_camis,
    SUM(NULLIF(TRIM(DBA), '') IS NULL) AS missing_dba,
    SUM(NULLIF(TRIM(BORO), '') IS NULL) AS missing_boro,
    SUM(NULLIF(TRIM(`CUISINE DESCRIPTION`), '') IS NULL) AS missing_cuisine,
    SUM(NULLIF(TRIM(`INSPECTION DATE`), '') IS NULL) AS missing_inspection_date,
    SUM(NULLIF(TRIM(`INSPECTION TYPE`), '') IS NULL) AS missing_inspection_type,
    SUM(NULLIF(TRIM(`VIOLATION CODE`), '') IS NULL) AS missing_violation_code,
    SUM(NULLIF(TRIM(`CRITICAL FLAG`), '') IS NULL) AS missing_critical_flag,
    SUM(NULLIF(TRIM(SCORE), '') IS NULL) AS missing_score,
    SUM(NULLIF(TRIM(GRADE), '') IS NULL) AS missing_grade
FROM restaurant_inspections_raw;


-- 1.3 查看 Borough 分布
-- Borough 中的 0 不代表真实行政区

SELECT
    BORO,
    COUNT(*) AS row_count
FROM restaurant_inspections_raw
GROUP BY BORO
ORDER BY row_count DESC;


-- 1.4 检查占位日期
-- 1900 日期是占位值，后面转为 NULL

SELECT
    SUM(TRIM(`INSPECTION DATE`) = '01/01/1900') AS placeholder_inspection_dates,
    SUM(TRIM(`GRADE DATE`) = '01/01/1900') AS placeholder_grade_dates
FROM restaurant_inspections_raw;


-- 1.5 检查 Score
-- 确认 Score 除空值外都是数字

SELECT
    SCORE,
    COUNT(*) AS row_count
FROM restaurant_inspections_raw
WHERE NULLIF(TRIM(SCORE), '') IS NOT NULL
  AND TRIM(SCORE) NOT REGEXP '^[0-9]+([.][0-9]+)?$'
GROUP BY SCORE;





-- 2. 创建清洗 View

-- 2.1 创建 violation 粒度的清洗 View
-- 一行代表一条 violation，同一次 inspection 可能有多条记录

CREATE OR REPLACE VIEW v_violation_record_clean AS
SELECT
    NULLIF(TRIM(CAMIS), '') AS CAMIS,
    NULLIF(TRIM(DBA), '') AS DBA,

    CASE
        WHEN NULLIF(TRIM(BORO), '') IS NULL OR TRIM(BORO) = '0' THEN NULL
        ELSE TRIM(BORO)
    END AS BORO,

    NULLIF(TRIM(BUILDING), '') AS BUILDING,
    NULLIF(TRIM(STREET), '') AS STREET,
    NULLIF(TRIM(ZIPCODE), '') AS ZIPCODE,
    NULLIF(TRIM(PHONE), '') AS PHONE,
    NULLIF(TRIM(`CUISINE DESCRIPTION`), '') AS `CUISINE DESCRIPTION`,

    CASE
        WHEN NULLIF(TRIM(`INSPECTION DATE`), '') IS NULL THEN NULL
        WHEN TRIM(`INSPECTION DATE`) = '01/01/1900' THEN NULL
        ELSE STR_TO_DATE(TRIM(`INSPECTION DATE`), '%m/%d/%Y')
    END AS `INSPECTION DATE`,

    NULLIF(TRIM(ACTION), '') AS ACTION,
    NULLIF(TRIM(`VIOLATION CODE`), '') AS `VIOLATION CODE`,
    NULLIF(TRIM(`VIOLATION DESCRIPTION`), '') AS `VIOLATION DESCRIPTION`,
    NULLIF(TRIM(`CRITICAL FLAG`), '') AS `CRITICAL FLAG`,
    CAST(NULLIF(TRIM(SCORE), '') AS DECIMAL(10, 2)) AS SCORE,
    NULLIF(TRIM(GRADE), '') AS GRADE,

    CASE
        WHEN NULLIF(TRIM(`GRADE DATE`), '') IS NULL THEN NULL
        WHEN TRIM(`GRADE DATE`) = '01/01/1900' THEN NULL
        ELSE STR_TO_DATE(TRIM(`GRADE DATE`), '%m/%d/%Y')
    END AS `GRADE DATE`,

    CASE
        WHEN NULLIF(TRIM(`RECORD DATE`), '') IS NULL THEN NULL
        ELSE STR_TO_DATE(TRIM(`RECORD DATE`), '%m/%d/%Y')
    END AS `RECORD DATE`,

    NULLIF(TRIM(`INSPECTION TYPE`), '') AS `INSPECTION TYPE`,
    CAST(NULLIF(TRIM(Latitude), '') AS DECIMAL(10, 7)) AS Latitude,
    CAST(NULLIF(TRIM(Longitude), '') AS DECIMAL(11, 7)) AS Longitude,
    NULLIF(TRIM(`Community Board`), '') AS `Community Board`,
    NULLIF(TRIM(`Council District`), '') AS `Council District`,
    NULLIF(TRIM(`Census Tract`), '') AS `Census Tract`,
    NULLIF(TRIM(BIN), '') AS BIN,
    NULLIF(TRIM(BBL), '') AS BBL,
    NULLIF(TRIM(NTA), '') AS NTA,
    NULLIF(TRIM(`Location Point1`), '') AS `Location Point1`
FROM restaurant_inspections_raw;





-- 3. 验证清洗 View

-- 3.1 检查清洗前后行数
-- View 没有删除记录，行数应该与原始表一致

SELECT
    (SELECT COUNT(*) FROM restaurant_inspections_raw) AS raw_row_count,
    (SELECT COUNT(*) FROM v_violation_record_clean) AS clean_row_count;


-- 3.2 检查清洗后的日期和 Score 范围

SELECT
    MIN(`INSPECTION DATE`) AS earliest_inspection_date,
    MAX(`INSPECTION DATE`) AS latest_inspection_date,
    MIN(SCORE) AS minimum_score,
    MAX(SCORE) AS maximum_score
FROM v_violation_record_clean;


-- 3.3 确认 1900 占位日期已经处理

SELECT
    SUM(`INSPECTION DATE` = '1900-01-01') AS remaining_inspection_dates,
    SUM(`GRADE DATE` = '1900-01-01') AS remaining_grade_dates
FROM v_violation_record_clean;