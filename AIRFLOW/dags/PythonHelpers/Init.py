from sqlalchemy import create_engine, text
import psycopg2
import os

def init_sql():

    conn = None
    cur = None

    try:
        conn = psycopg2.connect(
                host="warehouse",
                port=5432,
                user=os.environ["WAREHOUSE_USER"],
                password=os.environ["WAREHOUSE_PASSWORD"],
                dbname="bikeshare"
            )

        cur = conn.cursor()
        cur.execute("CREATE SCHEMA IF NOT EXISTS bronze")
        cur.execute("CREATE SCHEMA IF NOT EXISTS silver")
        cur.execute("CREATE SCHEMA IF NOT EXISTS gold")
        conn.commit()

    except Exception as E:
        print(f"Exception: {E}")
        raise

    finally:
        if cur is not None:
            cur.close()
        if conn is not None:
            conn.close()