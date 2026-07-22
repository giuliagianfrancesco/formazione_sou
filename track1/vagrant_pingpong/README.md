# Vagrant Docker Ping-Pong

Il progetto fa scambiare l'esecuzione di un servizio Docker tra due Macchine Virtuali (VM) ogni 60 secondi, utilizzando un file di stato condiviso come semaforo.

---

## Quick Start

Per avviare l'intero ambiente, esegui questo comando nella directory principale del progetto:

```bash
vagrant up
```

### Endpoint di Accesso
Il servizio demo (`ealen/echo-server`) risponde ai seguenti indirizzi a seconda di quale VM sia attiva in quel momento:

* **VM1 Attiva:** `http://localhost:3001`
* **VM2 Attiva:** `http://localhost:3002`

---

## Architettura e Funzionamento

Il sistema si basa su quattro componenti chiave coordinati in modo sincrono:

1. **Infrastruttura Multi-Node:** Vagrant istanzia due macchine virtuali separate (`vm1` e `vm2`) basate su Ubuntu 22.04 LTS.
2. **Stato Condiviso:** Entrambi i nodi monitorano costantemente il file `/vagrant/turno.txt` all'interno della directory sincronizzata di Vagrant.
3. **Ciclo di Esecuzione (Ping-Pong):**
   * La VM che legge il proprio hostname all'interno di `turno.txt` avvia il container Docker.
   * Il container rimane attivo per 60 secondi per servire le richieste.
   * Allo scadere del minuto, la VM killa il proprio container e scrive l'hostname dell'altra VM nel file di stato.
4. **Ispezione dei Log:** Per osservare il passaggio del testimone in tempo reale, accedi a una delle VM e lancia:
   ```bash
   tail -f ~/pingpong.log
   ```

---

## Comandi Essenziali


| Obiettivo | Comando | Descrizione |
| :--- | :--- | :--- |
| **Avvio** | `vagrant up` | Crea, configura e avvia le due VM. |
| **Stato** | `vagrant status` | Mostra lo stato attuale delle macchine virtuali. |
| **Arresto**| `vagrant halt` | Spegne i nodi senza eliminare i dati. |
| **Reset** | `vagrant destroy -f && vagrant up` | Rimuove completamente i nodi e rigenera l'ambiente da zero. |
| **SSH** | `vagrant ssh vm1` (o `vm2`) | Accede alla shell della macchina virtuale specificata. |

---

## Struttura dei File

Per il corretto funzionamento, la directory del progetto deve essere organizzata come segue prima del lancio:

* `Vagrantfile`: Configurazione dei nodi e del port forwarding.
* `script.sh`: Script di provisioning per l'installazione automatica di Docker.
* `pingpong.sh`: Lo script Bash che gestisce la logica di switch temporizzato.
* `turno.txt`: Il file di sincronizzazione (creato automaticamente o manualmente con scritto `vm1`).
