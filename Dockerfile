FROM apache/airflow:2.10.2

USER airflow

# 1. Ставим пакеты для Airflow и Cosmos в основное окружение
COPY af_requirements.txt /af_requirements.txt
RUN pip install --no-cache-dir -r /af_requirements.txt

# 2. Ставим dbt-clickhouse в изолированный venv, чтобы не сломать зависимости Airflow
RUN python -m venv /opt/airflow/dbt_venv && \
    /opt/airflow/dbt_venv/bin/pip install --no-cache-dir dbt-clickhouse==1.10.3

# 3. Копируем код и выдаем права пользователю 50000
COPY --chown=50000:0 dags/ /opt/airflow/dags/
COPY --chown=50000:0 dbt_project/ /opt/airflow/dbt_project/

# 4. Временные файлы dbt пишем в /tmp
ENV DBT_TARGET_PATH=/tmp/dbt_target
ENV DBT_LOG_PATH=/tmp/dbt_logs
