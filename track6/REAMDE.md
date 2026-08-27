# Esercizio Track 6: metrica custom

Esercizio aggiuntivo alla Track 6 sulla strumentazione manuale delle metriche OpenTelemetry: Aggiunta di un contatore custom che traccia il traffico HTTP ricevuto dall'applicazione Flask.

## Architettura

```
Flask app (name_counter custom)
   │  OTLP (grpc)
   ▼
OTel Collector
   │  receiver: otlp (grpc :4317, http :4318)
   │  processors: memory_limiter → batch
   │  exporter: prometheus (:9464, pull)
   ▼
Prometheus (scrape su otel-collector:9464)
   ▼
Grafana (datasource Prometheus)
```

## Implementazione

### Codice (`app.py`)

```python
from flask import Flask, request
from opentelemetry import metrics

app = Flask(__name__)

# Meter di OpenTelemetry
meter = metrics.get_meter("my_custom_meter")

# contatore personalizzato
name_counter = meter.create_counter(
    name="total_name",
    description="Conta volte che stampa il nome"
)
name = ["Giulia", "pippo", "Luca"]

@app.route("/")
def home():
    import random
    r = random.randint(0,2)
    nome_estratto = name[r]

    # incrementa il contatore
    name_counter.add(1, {
        "printed_name": nome_estratto
    })

    return f"Nome estratto: {nome_estratto}"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

### Spiegazione

`from opentelemetry import metrics` importa il modulo dell'API OpenTelemetry dedicato alle metriche.

`metrics.get_meter("my_custom_meter")` — Ottiene un **Meter**, l'oggetto tramite cui l'SDK crea strumenti di misurazione (counter, histogram, gauge, ecc.). `my_custom_meter` identifica la libreria/modulo che genera questa metrica.

`meter.create_counter(name=..., description=...)` — Crea uno strumento di tipo **counter**: un valore cumulativo dall'avvio del processo. `name` è l'identificativo della metrica.

`name_counter.add(1, {"printed_name": nome_estratto})` — Incrementa il counter di 1 unità, associando un **attributo** (`printed_name`) con il valore estratto casualmente. Ogni combinazione distinta di attributi genera una serie temporale separata su Prometheus.

**L'array dei nomi**

```python
name = ["Giulia", "pippo", "Luca"]
```

Un elenco statico usato per simulare un dato variabile da associare alla metrica.

```python
@app.route("/")
def home():
    import random
    r = random.randint(0,2)
    nome_estratto = name[r]

    name_counter.add(1, {
        "printed_name": nome_estratto
    })

    return f"Nome estratto: {nome_estratto}"
```

Ad ogni richiesta HTTP su `/`:
- `random.randint(0,2)` genera un indice casuale tra 0 e 2 (inclusi), sufficiente a coprire i tre elementi dell'array (indici 0, 1, 2)
- `nome_estratto` è il nome scelto per questa specifica richiesta
- `name_counter.add(1, {"printed_name": nome_estratto})` è la riga che genera davvero il dato di telemetria: incrementa il counter di 1 unità, e associa a questo incremento un attributo (in terminologia Prometheus, una "label") chiamato `printed_name`, con valore pari al nome estratto

**Avvio dell'app**

```python
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

`host="0.0.0.0"` è necessario per rendere l'app raggiungibile da fuori il container.

### `otel-collector-config.yaml`

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
processors:
  batch:
  memory_limiter:
    check_interval: 1s
    limit_mib: 460

exporters:
    prometheus:
      endpoint: 0.0.0.0:9464

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [prometheus]
```

Nessuna modifica rispetto alla track 6 base per supportare la metrica custom: l'exporter `prometheus` standard esporta comunque la custom metric ricevuta dal receiver.

### `podman-compose.yml`

```yaml
services:
  app-python:
    build: ./
    ports:
      - "5000:5000"
  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.95.0
    ports:
      - "4317:4317"
      - "4318:4318"
      - "9464:9464"
    volumes:
      - ./otel-collector-config.yaml:/etc/otelcol-contrib/config.yaml
    command: ["--config=/etc/otelcol-contrib/config.yaml"]
  prometheus:
    image: docker.io/prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
```

**Avvio di tutti i servizi**
```bash
podman-compose up -d
```

**Stato dei container**
```bash
podman ps
```

**Log di un servizio**
```bash
podman logs <id-o-nome-container>
```

**Arresto e rimozione di tutti i container dello stack**
```bash
podman-compose down
```

## Verifica

```bash
# 1. Generare traffico verso l'app
curl http://localhost:5000/

# 2. Verifica l'esposizione finale in formato Prometheus
curl -s http://localhost:9464/metrics | grep name_total

# 3. Verifica su grafana
curl http://localhost:3000/
```

Output atteso al punto 3 (valori solo di esempio):
```
# HELP name_total Conta volte che stampa il nome
# TYPE name_total counter
name_total{job="python-flask-app",printed_name="Giulia"} 4
name_total{job="python-flask-app",printed_name="Luca"} 6
name_total{job="python-flask-app",printed_name="pippo"} 10
```
