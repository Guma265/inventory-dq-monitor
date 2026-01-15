DROP TABLE IF EXISTS stg_inventory_snapshot;
DROP TABLE IF EXISTS dim_category_allowed;

CREATE TABLE stg_inventory_snapshot (
  snapshot_date   TEXT,
  sku             TEXT,
  product_name    TEXT,
  category        TEXT,
  supplier_id     TEXT,
  unit_cost       REAL,
  unit_price      REAL,
  stock_on_hand   INTEGER,
  reorder_point   INTEGER
);

CREATE TABLE dim_category_allowed (
  category TEXT PRIMARY KEY
);

INSERT INTO dim_category_allowed(category) VALUES
('FILAMENT_PLA'),
('FILAMENT_PETG'),
('FILAMENT_ABS_ASA'),
('RESIN'),
('NOZZLES'),
('SPARES'),
('TOOLS'),
('ADHESIVES'),
('ELECTRONICS'),
('UPGRADES');
