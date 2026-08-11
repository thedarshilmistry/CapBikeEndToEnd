from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from PythonHelpers.Intake import make_bronze
from PythonHelpers.Init import init_sql
# from PythonHelpers.SQLRunner import Runner
from airflow.operators.bash import BashOperator
from airflow.providers.docker.operators.docker import DockerOperator
from docker.types import Mount


# runner = Runner()

with DAG(
    dag_id = "capital_bikeshare_pipeline",
    start_date = datetime(2002, 1, 1),
    schedule = None,
    catchup = False,
) as dag:

    initiator = PythonOperator(
        task_id = "initiate_schemas",
        python_callable = init_sql
    )

    extraction = PythonOperator(
        task_id="extract_data",
        python_callable = make_bronze,
        op_kwargs={"year": "{{ logical_date.year }}", "month": "{{ logical_date.month }}"},
    )

    docker_dbt = BashOperator(
        task_id="dbt_run",
        bash_command=(
            "/opt/airflow/dbt_venv/bin/dbt run --project-dir /opt/airflow/dbt/cp_bikeshare --target container"
        ),
    )

    initiator >> extraction >> docker_dbt

