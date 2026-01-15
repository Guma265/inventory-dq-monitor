WITH base AS (
  SELECT
    snapshot_date,
    sku,
    TRIM(COALESCE(sku,'')) AS sku_trim,
    category,
    unit_cost,
    unit_price,
    stock_on_hand
  FROM stg_inventory_snapshot
),
issues AS (

  -- 1) SKU nulo o vacío
  SELECT
    snapshot_date,
    'NULL_OR_EMPTY_KEY' AS issue_type,
    'HIGH' AS severity,
    COUNT(*) AS affected_rows,
    GROUP_CONCAT(COALESCE(sku,'(NULL)'), ', ') AS sample_keys
  FROM base
  WHERE sku IS NULL OR sku_trim = ''
  GROUP BY snapshot_date

  UNION ALL

  -- 2) Stock negativo
  SELECT
    snapshot_date,
    'NEGATIVE_STOCK' AS issue_type,
    'HIGH' AS severity,
    COUNT(*) AS affected_rows,
    GROUP_CONCAT(sku_trim, ', ') AS sample_keys
  FROM base
  WHERE sku_trim <> '' AND stock_on_hand < 0
  GROUP BY snapshot_date

  UNION ALL

  -- 3) Precio por debajo del costo (margen negativo)
  SELECT
    snapshot_date,
    'PRICE_BELOW_COST' AS issue_type,
    'HIGH' AS severity,
    COUNT(*) AS affected_rows,
    GROUP_CONCAT(sku_trim, ', ') AS sample_keys
  FROM base
  WHERE sku_trim <> '' AND unit_price < unit_cost
  GROUP BY snapshot_date

  UNION ALL

  -- 4) Duplicados por clave (snapshot_date + sku)
  SELECT
    snapshot_date,
    'DUPLICATE_KEYS' AS issue_type,
    'HIGH' AS severity,
    SUM(cnt - 1) AS affected_rows,
    GROUP_CONCAT(sku_trim, ', ') AS sample_keys
  FROM (
    SELECT snapshot_date, sku_trim, COUNT(*) AS cnt
    FROM base
    WHERE sku_trim <> ''
    GROUP BY snapshot_date, sku_trim
    HAVING COUNT(*) > 1
  )
  GROUP BY snapshot_date

  UNION ALL

  -- 5) Formato de fecha inválido
  SELECT
    snapshot_date,
    'BAD_DATE_FORMAT' AS issue_type,
    'MED' AS severity,
    COUNT(*) AS affected_rows,
    GROUP_CONCAT(COALESCE(sku,'(NULL)'), ', ') AS sample_keys
  FROM base
  WHERE snapshot_date IS NULL OR snapshot_date NOT GLOB '????-??-??'
  GROUP BY snapshot_date

  UNION ALL

  -- 6) Categoría inválida
  SELECT
    b.snapshot_date,
    'INVALID_CATEGORY' AS issue_type,
    'MED' AS severity,
    COUNT(*) AS affected_rows,
    GROUP_CONCAT(b.sku_trim, ', ') AS sample_keys
  FROM base b
  LEFT JOIN dim_category_allowed d
    ON TRIM(COALESCE(b.category,'')) = d.category
  WHERE b.sku_trim <> ''
    AND (d.category IS NULL)
  GROUP BY b.snapshot_date
)

SELECT
  snapshot_date,
  issue_type,
  severity,
  affected_rows,
  SUBSTR(sample_keys, 1, 120) AS sample_keys
FROM issues
WHERE affected_rows > 0
ORDER BY
  CASE severity WHEN 'HIGH' THEN 1 WHEN 'MED' THEN 2 ELSE 3 END,
  issue_type,
  snapshot_date;
