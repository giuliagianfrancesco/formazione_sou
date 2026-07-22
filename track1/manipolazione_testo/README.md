# Esercizi Bash: Analisi file di Log e consumo medio CPU

## 1. Esercizio 1:

Il primo script analizza un file di log (passato in input al momento dell'esecuzione e letto con $1) con una serie di indirizzi IP di cui dobbiamo trovare i 3 più ricorrenti.

**Struttura soluzione:**
* **sort**: Ordina per indirizzi IP il file 
* **uniq -c**: Elimina i duplicati e calcola il numero di ricorrenza di ciascun IP (con -c)
* **sort -r**: Ordina per numero di ricorrenze ma questa volta in ordine decrescente (con -r)
* **head**: Restituisce solamente i primi n IP con il relativo numero di ricorrenza

Ho scelto l'utilizzo dei comandi di Linux per semplificare la scrittura e il costo computazionale del codice evitando cicli per lettura e ordinamento file. In un'unica riga gestita con le pipe ho direttamente la soluzione

## 2. Esercizio 2:
Il secondo script calcola la percentuale media di uso della CPU per ogni server presente nel file metriche.txt.

**Struttura soluzione:**
* **Primo ciclo (while):** Tramite il comando "read -r" lo script legge ogni riga del file, separandone i due valori che associa poi alle due variabili "server" e "cpu".  In questo modo può inserire nei due array associativi (entrambi con chiave "server") il valore della CPU totale utilizzata e del numero di ricorrenze.
* **Secondo ciclo (for):** Lo script esegue un ciclo sugli indici dell'array (utilizzando !) quindi sui server. Per ogni server calcola la media che viene poi stampata con "echo".
