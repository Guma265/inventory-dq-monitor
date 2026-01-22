-- =========================================
-- Inventory DQ Monitor - Pipeline Reports
-- =========================================

-- 1) Quality overview per run
-- Detects overall data quality and rejection volume

SELECT
  run_id,
  COUNT(*)                        AS files_processed,
  ROUND(AVG(reject_rate), 3)      AS avg_reject_rate,
  SUM(rows_rejected)              AS total_rejected_rows,
  SUM(rows_in)                    AS total_rows
FROM etl_quality_metrics
GROUP BY run_id
ORDER BY run_id DESC;


-- 2) Stability score per run
-- 1.0 = perfect, <0.9 warning, <0.8 alert

SELECT
  run_id,
  ROUND(
    1.0 - (SUM(rows_rejected) * 1.0 / NULLIF(SUM(rows_in), 0)),
    3
  ) AS stability_score
FROM etl_quality_metrics
GROUP BY run_id
ORDER BY run_id DESC;


-- 3) Performance trend by day
-- Detects execution time degradation

SELECT
  substr(created_at_utc, 1, 10) AS day,
  COUNT(*)                     AS files_processed,
  ROUND(AVG(duration_ms), 1)   AS avg_duration_ms
FROM etl_quality_metrics
GROUP BY day
ORDER BY day;
