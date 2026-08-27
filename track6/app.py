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
