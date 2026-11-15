FROM apache/airflow:2.10.2
COPY af_requirements.txt /af_requirements.txt
RUN pip install --no-cache-dir -r /af_requirements.txt
