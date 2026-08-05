from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from PythonHelpers.Intake import make_bronze
from PythonHelpers.Init import make_schemas
from PythonHelpers.SQLRunner import Runner
from airflow.operators.bash import BashOperator


runner = Runner()

with DAG(
    dag_id = "capital_bikeshare_pipeline",
    start_date = datetime(2002, 1, 1),
    schedule = None,
    catchup = False,
) as dag:

    initiator = PythonOperator(
        task_id = "initiate_schemas",
        python_callable = make_schemas
    )

    extraction = PythonOperator(
        task_id="extract_data",
        python_callable = make_bronze,
        op_kwargs={"year": "{{ logical_date.year }}", "month": "{{ logical_date.month }}"},
    )


    dbt = BashOperator(
        task_id = "quarantine_bad_rows",
        bash_command = "cd /opt/dbt/ && dbt run --profiles-dir /opt/dbt/profiles --target docker"
    )


    initiator >> extraction >> dbt

