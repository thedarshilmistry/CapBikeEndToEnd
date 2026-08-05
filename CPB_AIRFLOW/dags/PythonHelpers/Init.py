import duckdb

def make_schemas():

    try:
        con = duckdb.connect('/opt/dbt/Data/Processed/bikeshare.duckdb')

        result = con.execute("""
        CREATE SCHEMA IF NOT EXISTS BRONZE;
        CREATE SCHEMA IF NOT EXISTS SILVER;
        CREATE SCHEMA IF NOT EXISTS GOLD;
        CHECKPOINT;
        """).fetchall()

        con.close()
        print(f"con closed -> {result}")

    except Exception as E:
        print(f"ERROR>>>>>>>>>>>>{E}")

    finally:
        con.close()
        print("con closed")