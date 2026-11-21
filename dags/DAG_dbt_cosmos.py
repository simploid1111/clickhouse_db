from datetime import datetime
from pathlib import Path
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import ClickhouseUserPasswordProfileMapping

DBT_PROJECT_PATH = Path("/opt/airflow/dbt_project")

profile_config = ProfileConfig(
    profile_name="bi_dwh_project",
    target_name="prod",
    profile_mapping=ClickhouseUserPasswordProfileMapping(
        conn_id="clickhouse_conn",
        profile_args={
            "schema": "prod",
            "port": 8123,
            "secure": False,
        },
    ),
)

clickhouse_dbt_dag = DbtDag(
    project_config=ProjectConfig(DBT_PROJECT_PATH),
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        # Если dbt установлен в системный python внутри Dockerfile:
        dbt_executable_path="/home/airflow/.local/bin/dbt",
    ),
    dag_id="clickhouse_dbt_pipeline",
    schedule="@daily",
    start_date=datetime(2026, 11, 20),
    catchup=False,
    default_args={"retries": 1},
)
