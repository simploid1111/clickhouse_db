from datetime import datetime
from airflow.decorators import dag, task
from airflow.hooks.base import BaseHook  # Used in Airflow 3 to fetch connections
import clickhouse_driver

@dag(
    dag_id='check_airflow',
    schedule='@daily',           # Replaced 'schedule_interval' in newer Airflow versions
    start_date=datetime(2026, 11, 11),
    catchup=False,
    tags=['clickhouse', 'check']
)
def check_clickhouse_dag():
    @task
    def test_clickhouse_connection():
        # Fetch connection details stored in the Airflow UI
        conn = BaseHook.get_connection('clickhouse_conn')
        
        client = clickhouse_driver.Client(
            host=conn.host,
            port=conn.port or 9000,
            user=conn.login,
            password=conn.password,
            database=conn.schema or 'default'
        )
        
        result = client.query_dataframe('SELECT version()')['version__'].iloc[0]
        print(f"Connected successfully! ClickHouse version: {result}")
        return result

    test_clickhouse_connection()

check_clickhouse_dag()
