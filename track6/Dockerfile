FROM python:3.9-slim

WORKDIR /appFlask

COPY requirements.txt /appFlask

# Install dependencies using a cache to save dependency installation. 
# When requirements.txt changes the cache maintains the old dependencies and only new dependencies are installed
# target/root/.cache/pip is the default directory where pip stores dependencies. It is copied in the PC and used as a cache in the next build.
RUN --mount=type=cache,target=/root/.cache/pip pip3 install -r requirements.txt

COPY app.py /appFlask

ENTRYPOINT ["opentelemetry-instrument", "--log_level", "debug", "--service_name", "python-flask-app", "--metrics_exporter", "otlp", "--traces_exporter", "otlp", "--exporter_otlp_endpoint", "otel-collector:4317", "--exporter_otlp_insecure", "true", "python3", "app.py"]                                                      
