# inventory-dq-monitor
Proyecto en SQL enfocado en detectar, medir y monitorear problemas de calidad de datos en inventarios, incluyendo valores nulos, inconsistencias, duplicados y reglas de integridad, con métricas claras para análisis y toma de decisiones.

# Inventory DQ Monitor (3D Printing) — SQLite + SQL + Python

Mini-proyecto reproducible de Data Analyst / Data Engineer Jr: carga snapshots diarios de inventario (CSV) a SQLite, ejecuta checks de calidad de datos (DQ) y genera reportes en CSV listos para análisis.

## Qué hace (en 30 segundos)
- Carga 3 snapshots diarios** de inventario desde `data_raw/` a SQLite (staging).
- Ejecuta validaciones de calidad (claves, duplicados, negativos, fechas, categorías).
- Genera outputs en `outputs/`:
  - `daily_inventory_report.csv`: métricas agregadas por día
  - `dq_issues_report.csv`: issues de calidad por día con severidad

## Estructura del repositorio
inventory-dq-monitor/
data_raw/ 
sql/ 
outputs/ 
run_pipeline.py
requirements.txt
.gitignore
README.md

## Inputs y Outputs

### Inputs
- `data_raw/inventory_snapshot_2026-01-15.csv`
- `data_raw/inventory_snapshot_2026-01-16.csv`
- `data_raw/inventory_snapshot_2026-01-17.csv`

Columnas principales:
- `snapshot_date, sku, product_name, category, supplier_id, unit_cost, unit_price, stock_on_hand, reorder_point`

### Outputs
- `outputs/daily_inventory_report.csv`
  - `snapshot_date`
  - `total_skus`
  - `total_stock_units`
  - `inventory_value_cost`
  - `inventory_value_retail`
  - `low_stock_skus`
  - `out_of_stock_skus`

- `outputs/dq_issues_report.csv`
  - `snapshot_date`
  - `issue_type`
  - `severity` (HIGH/MED/LOW)
  - `affected_rows`
  - `sample_keys` (muestra de SKUs afectados)

---

## Cómo correrlo (rápido)

### 1) Crear entorno e instalar dependencias
```bash
python -m venv .venv
source .venv/bin/activate   # macOS/Linux
# .venv\Scripts\activate    # Windows

pip install -r requirements.txt
2) Ejecutar pipeline
python run_pipeline.py
3) Ver resultados
Revisa la carpeta outputs/:
daily_inventory_report.csv
dq_issues_report.csv
Checks de calidad de datos (DQ)
Este proyecto detecta issues típicos de datos operativos:
HIGH

NULL_OR_EMPTY_KEY: SKU nulo o vacío
DUPLICATE_KEYS: duplicados por (snapshot_date + sku)
NEGATIVE_STOCK: stock negativo
PRICE_BELOW_COST: precio por debajo del costo (margen negativo)
MED
BAD_DATE_FORMAT: fecha en formato inválido (esperado YYYY-MM-DD)
INVALID_CATEGORY: categoría fuera del catálogo permitido
Diseño: se usa dim_category_allowed como catálogo para validar categorías.

## Autor
Guillermo MR  
Data Analyst / Data Engineer Jr  
