-- =========================================
-- Inventory DQ Monitor - Data Quality Issues
-- =========================================

-- 1) Top rejection causes across all runs
-- Identifies systematic data quality problems

SELECT
  reason,
  COUNT(*) AS occurrences
FROM (
  SELECT
    trim(value) AS reason
  FROM etl_quality_metrics,
       json_each(reason_counts_json)
)
GROUP BY reason
ORDER BY occurrences DESC;


-- 2) Files that broke the quality gate
-- Helps identify problematic sources

SELECT
  run_id,
  file_path,
  reject_rate,
  rows_rejected,
  rows_in
FROM etl_quality_metrics
WHERE reject_rate > 0.2
ORDER BY reject_rate DESC;


-- 3) Rejected rows by file (volume perspective)

SELECT
  file_path,
  SUM(rows_rejected) AS total_rejected_rows
FROM etl_quality_metrics
GROUP BY file_path
ORDER BY total_rejected_rows DESC;
