FROM apache/airflow:2.10.2

# Переключаемся на системного пользователя airflow
USER airflow

COPY af_requirements.txt /af_requirements.txt
RUN pip install --no-cache-dir -r /af_requirements.txt

# 2. Копируем папки с кодом внутрь образа и сразу выдаем права пользователю 50000
COPY --chown=50000:0 dags/ /opt/airflow/dags/
COPY --chown=50000:0 dbt_project/ /opt/airflow/dbt_project/

# 3. Указываем dbt сохранять временные файлы (target и logs) в системную папку /tmp
ENV DBT_TARGET_PATH=/tmp/dbt_target
ENV DBT_LOG_PATH=/tmp/dbt_logs