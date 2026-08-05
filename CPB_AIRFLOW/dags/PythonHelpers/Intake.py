import pandas as pd
import requests
import zipfile
from io import BytesIO
import duckdb

def make_bronze(year, month):

    print(month)

    if len(month) == 1:
        month = "0" + month

    print(month)

    request_url = f'https://s3.amazonaws.com/capitalbikeshare-data/{year}{month}-capitalbikeshare-tripdata.zip'

    response = requests.get(request_url, allow_redirects=True)

    raw_path = f'/opt/dbt/Data/Raw/{year}/{month}'

    print(request_url)

    try:
        zip = zipfile.ZipFile(BytesIO(response.content))
        zip.extractall(raw_path)

        con = duckdb.connect('/opt/dbt/Data/Processed/bikeshare.duckdb')

        df = pd.read_csv(f'{raw_path}/{year}{month}-capitalbikeshare-tripdata.csv')

        result = con.execute("""
        CREATE OR REPLACE TABLE BRONZE.raw_trips AS SELECT * FROM df;
        CHECKPOINT;

        """).fetchall()

        con.close()
        print(f"con closed -> {result}")

    except:
        print(response.status_code)

    finally:
        con.close()
        print("con closed")