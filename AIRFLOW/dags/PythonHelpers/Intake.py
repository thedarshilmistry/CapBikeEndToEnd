import pandas as pd
import requests
import zipfile
from io import BytesIO
import psycopg2
from sqlalchemy import create_engine
import os


def make_bronze(year, month):

    print(month)

    if len(month) == 1:
        month = "0" + month

    print(month)

    request_url = f'https://s3.amazonaws.com/capitalbikeshare-data/{year}{month}-capitalbikeshare-tripdata.zip'
    engine_uri = (
        f"postgresql+psycopg2://{os.environ['WAREHOUSE_USER']}"
        f":{os.environ['WAREHOUSE_PASSWORD']}"
        f"@warehouse:5432/bikeshare"
    )
    raw_path = f'/opt/airflow/dbt/Data/Raw/{year}/{month}'

    print(request_url)

    try:
        response = requests.get(request_url, allow_redirects=True)
        zip = zipfile.ZipFile(BytesIO(response.content))
        zip.extractall(raw_path)

        df = pd.read_csv(f'{raw_path}/{year}{month}-capitalbikeshare-tripdata.csv')

        engine = create_engine(engine_uri)

        df.to_sql(
            "trips",
            engine,
            schema="bronze",
            if_exists="replace",
            index=False,
        )

    except Exception as E:
        print(f"Exception {E}")
        raise