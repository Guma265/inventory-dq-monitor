-- Reporte diario (agregado)
WITH cleaned AS (
  SELECT
    snapshot_date,
    TRIM(sku) AS sku,
    unit_cost,
    unit_price,
    stock_on_hand,
    reorder_point
  FROM stg_inventory_snapshot
  WHERE sku IS NOT NULL AND TRIM(sku) <> ''
    AND snapshot_date GLOB '????-??-??'  -- formato esperado YYYY-MM-DD
)
SELECT
  snapshot_date,
  COUNT(DISTINCT sku) AS total_skus,
  SUM(stock_on_hand) AS total_stock_units,
  ROUND(SUM(stock_on_hand * unit_cost), 2) AS inventory_value_cost,
  ROUND(SUM(stock_on_hand * unit_price), 2) AS inventory_value_retail,
  SUM(CASE WHEN stock_on_hand <= reorder_point THEN 1 ELSE 0 END) AS low_stock_skus,
  SUM(CASE WHEN stock_on_hand = 0 THEN 1 ELSE 0 END) AS out_of_stock_skus
FROM cleaned
GROUP BY snapshot_date
ORDER BY snapshot_date;
