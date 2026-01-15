import sqlite3
import pandas as pd
from pathlib import Path

DB_PATH = Path("inventory.db")
DATA_RAW = Path("data_raw")
SQL_DIR = Path("sql")
OUT_DIR = Path("outputs")

CSV_FILES = [
    DATA_RAW / "inventory_snapshot_2026-01-15.csv",
    DATA_RAW / "inventory_snapshot_2026-01-16.csv",
    DATA_RAW / "inventory_snapshot_2026-01-17.csv",
]

def exec_sql_file(conn: sqlite3.Connection, path: Path) -> None:
    sql = path.read_text(encoding="utf-8")
    conn.executescript(sql)

def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(DB_PATH) as conn:
        # 1) Create tables + dim categories
        exec_sql_file(conn, SQL_DIR / "01_create_tables.sql")

        # 2) Load staging (append snapshots)
        for csv_path in CSV_FILES:
            df = pd.read_csv(csv_path)
            df.to_sql("stg_inventory_snapshot", conn, if_exists="append", index=False)

        # 3) Export daily report
        daily_sql = (SQL_DIR / "02_reports.sql").read_text(encoding="utf-8")
        daily_df = pd.read_sql_query(daily_sql, conn)
        daily_df.to_csv(OUT_DIR / "daily_inventory_report.csv", index=False)

        # 4) Export DQ issues
        dq_sql = (SQL_DIR / "03_dq_issues.sql").read_text(encoding="utf-8")
        dq_df = pd.read_sql_query(dq_sql, conn)
        dq_df.to_csv(OUT_DIR / "dq_issues_report.csv", index=False)

    print("OK: outputs generated in /outputs")

if __name__ == "__main__":
    main()
