-- NYC Restaurant Health Inspection Analysis
-- 使用清洗后的数据进行分析

USE nyc_restaurant_inspection;





-- 1. 整体情况

-- 1.1 检查数量、餐厅数量和平均分

SELECT
    COUNT(*) AS inspection_count,
    COUNT(DISTINCT CAMIS) AS restaurant_count,
    ROUND(AVG(SCORE), 2) AS average_score
FROM v_inspection_level;


-- 1.2 Grade分布

SELECT
    GRADE,
    COUNT(*) AS inspection_count
FROM v_inspection_level
WHERE GRADE IN ('A', 'B', 'C')
GROUP BY GRADE
ORDER BY inspection_count DESC;





-- 2. Borough分析

-- 2.1 各Borough检查数量和平均分

SELECT
    BORO,
    COUNT(*) AS inspection_count,
    ROUND(AVG(SCORE), 2) AS average_score
FROM v_inspection_level
WHERE BORO IS NOT NULL
GROUP BY BORO
ORDER BY inspection_count DESC;


-- 2.2 各Borough的Grade分布

SELECT
    BORO,
    GRADE,
    COUNT(*) AS inspection_count
FROM v_inspection_level
WHERE BORO IS NOT NULL
  AND GRADE IN ('A', 'B', 'C')
GROUP BY
    BORO,
    GRADE
ORDER BY
    BORO,
    GRADE;





-- 3. 时间趋势

-- 3.1 每年检查数量和平均分

SELECT
    YEAR(`INSPECTION DATE`) AS inspection_year,
    COUNT(*) AS inspection_count,
    ROUND(AVG(SCORE), 2) AS average_score
FROM v_inspection_level
GROUP BY YEAR(`INSPECTION DATE`)
ORDER BY inspection_year;


-- 3.2 每年Critical Violation Rate
-- Critical违规记录数 / 有效Critical Flag记录数

SELECT
    YEAR(`INSPECTION DATE`) AS inspection_year,
    SUM(`CRITICAL FLAG` = 'Critical') AS critical_violations,
    COUNT(*) AS valid_flag_records,
    ROUND(
        SUM(`CRITICAL FLAG` = 'Critical') * 100.0 / COUNT(*),
        2
    ) AS critical_violation_rate
FROM v_violation_record_clean
WHERE `INSPECTION DATE` IS NOT NULL
  AND `VIOLATION CODE` IS NOT NULL
  AND `CRITICAL FLAG` IN ('Critical', 'Not Critical')
GROUP BY YEAR(`INSPECTION DATE`)
ORDER BY inspection_year;





-- 4. Cuisine分析

-- 4.1 检查数量最多的Cuisine

SELECT
    `CUISINE DESCRIPTION`,
    COUNT(*) AS inspection_count,
    ROUND(AVG(SCORE), 2) AS average_score
FROM v_inspection_level
WHERE `CUISINE DESCRIPTION` IS NOT NULL
GROUP BY `CUISINE DESCRIPTION`
ORDER BY inspection_count DESC
LIMIT 10;





-- 5. Violation分析

-- 5.1 最常见的Violation Code

SELECT
    `VIOLATION CODE`,
    MAX(`VIOLATION DESCRIPTION`) AS violation_description,
    COUNT(*) AS violation_record_count
FROM v_violation_record_clean
WHERE `VIOLATION CODE` IS NOT NULL
GROUP BY `VIOLATION CODE`
ORDER BY violation_record_count DESC
LIMIT 10;


-- 5.2 各Borough的Critical Violation Rate

SELECT
    BORO,
    SUM(`CRITICAL FLAG` = 'Critical') AS critical_violations,
    COUNT(*) AS valid_flag_records,
    ROUND(
        SUM(`CRITICAL FLAG` = 'Critical') * 100.0 / COUNT(*),
        2
    ) AS critical_violation_rate
FROM v_violation_record_clean
WHERE BORO IS NOT NULL
  AND `VIOLATION CODE` IS NOT NULL
  AND `CRITICAL FLAG` IN ('Critical', 'Not Critical')
GROUP BY BORO
ORDER BY critical_violation_rate DESC;


-- 5.3 各Risk Area的Critical Violation Rate

SELECT
    BORO,
    NTA,
    SUM(`CRITICAL FLAG` = 'Critical') AS critical_violations,
    COUNT(*) AS valid_flag_records,
    ROUND(
        SUM(`CRITICAL FLAG` = 'Critical') * 100.0 / COUNT(*),
        2
    ) AS critical_violation_rate
FROM v_violation_record_clean
WHERE BORO IS NOT NULL
  AND NTA IS NOT NULL
  AND `VIOLATION CODE` IS NOT NULL
  AND `CRITICAL FLAG` IN ('Critical', 'Not Critical')
GROUP BY
    BORO,
    NTA
ORDER BY critical_violation_rate DESC;