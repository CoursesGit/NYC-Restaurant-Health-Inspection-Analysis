-- NYC Restaurant Health Inspection Analysis
-- 将 violation 记录汇总到 inspection 粒度

USE nyc_restaurant_inspection;





-- 1. 创建 inspection 粒度 View

-- 1.1 将多条 violation 记录汇总为一次 inspection
-- 原始数据没有 inspection ID
-- 使用 CAMIS、检查日期和检查类型近似识别一次检查
-- 当前有 3 个组合存在多个 Score 或 Action，因此不纳入 inspection 分析

CREATE OR REPLACE VIEW v_inspection_level AS
SELECT
    CAMIS,
    MAX(DBA) AS DBA,
    MAX(BORO) AS BORO,
    MAX(NTA) AS NTA,
    MAX(`CUISINE DESCRIPTION`) AS `CUISINE DESCRIPTION`,
    `INSPECTION DATE`,
    `INSPECTION TYPE`,
    MAX(ACTION) AS ACTION,
    MAX(SCORE) AS SCORE,
    MAX(GRADE) AS GRADE
FROM v_violation_record_clean
WHERE CAMIS IS NOT NULL
  AND `INSPECTION DATE` IS NOT NULL
  AND `INSPECTION TYPE` IS NOT NULL
GROUP BY
    CAMIS,
    `INSPECTION DATE`,
    `INSPECTION TYPE`
HAVING COUNT(DISTINCT SCORE) <= 1
   AND COUNT(DISTINCT ACTION) <= 1;





-- 2. 验证 inspection 粒度 View

-- 2.1 查看最终 inspection 数量

SELECT COUNT(*) AS inspection_count
FROM v_inspection_level;