FROM apache/airflow:2.10.2

COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /af_requirements.txt
