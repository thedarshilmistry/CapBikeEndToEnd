FROM apache/airflow:3.3.0

# airflow-side deps (providers, extract libs)
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# dbt in its own venv, isolated from airflow's dependency tree
RUN python -m venv /opt/airflow/dbt_venv && \
    /opt/airflow/dbt_venv/bin/pip install --no-cache-dir \
        "dbt-core~=1.10" "dbt-postgres~=1.9"