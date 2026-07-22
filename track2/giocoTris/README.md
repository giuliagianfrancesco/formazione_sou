Tris in Docker con Vagrant & Ansible

Implementazione del gioco del Tris orchestrata in un ambiente virtualizzato.
Il gioco utilizza Vagrant perla configurazione della macchina virtuale, Ansible come provision per la configurazione automatica e 11 container Docker distinti, ognuno dei quali rappresenta e conserva lo stato di una singola casella dello schema del tris e i due giocatori.

Architettura del Progetto 
Il progetto è suddiviso in tre strati principali:
Virtualizzazione (Vagrant): Crea una VM Ubuntu Jammy64 isolata.
Automazione (Ansible): Installa Docker sulla VM e istanzia 9 container Docker (da cas_1 a cas_9). Ogni container monta un volume locale che contiene un file .txt rappresentante lo stato della casella (V per Vuota, X o O per i giocatori). Istanzia poi due container giocatori.
Logica di Gioco (Bash): Uno script Bash che gestisce i turni, valida le mosse scrivendo direttamente dentro i container Docker tramite docker exec, stampa la griglia a schermo e verifica le condizioni di vittoria o pareggio.

Prerequisiti
Su host necessario:
Vagrant
VirtualBox

Installazione e Avvio
Seguire questi passaggi per configurare l'ambiente e avviare la partita:

1. Clona il progetto e prepara i file
Nella stessa cartella si deve avere:
- Vagrantfile (contenente la configurazione Vagrant)
- playbook.yml (contenente il playbook Ansible)
- script_tris.sh (lo script Bash del gioco)
- File di testo iniziali per le caselle (con valore di default V per indicare che sono vuote).

2. Avvia la Macchina Virtuale
Comando per creare la VM e avviare il provisioning automatico con Ansible:
```
Bash
vagrant up
```
Questo processo installerà Docker, scaricherà l'immagine di Ubuntu e avvierà i 9 container delle caselle  e i due giocatori.

3. Accedi alla VM
Una volta completato il setup, entrare all'interno della macchina virtuale tramite SSH:
```
Bash
vagrant ssh
```

4. Avvia il Gioco
Spostarsi nella directory condivisa (dove risiede lo script) ed esegui il gioco:
```
Bash
cd /vagrant
bash script_tris.sh
```

Come si Gioca:
Il gioco assegna automaticamente il simbolo X al Giocatore 1 e il simbolo O al Giocatore 2.
A ogni turno verrà chiesto di inserire un numero da 1 a 9.
La numerazione della griglia segue questo schema:

| | | |
| :---: | :---: | :---: |
| **1** | **2** | **3** |
| **4** | **5** | **6** |
| **7** | **8** | **9** |

Lo script controllerà se il container corrispondente ha il valore "V" al suo interno. Se libero, scriverà il simbolo del giocatore nel container e aggiornerà la griglia.
Il gioco termina quando un giocatore allinea 3 simboli (in orizzontale, verticale o diagonale) o quando vengono esaurite le 9 mosse (pareggio).

Pulizia dell'ambiente:
Quando hai finito di giocare, puoi spegnere e distruggere la macchina virtuale per liberare risorse sul tuo PC con un singolo comando:
Bash
vagrant destroy -f


Pseudo-code:

ALGORITMO OrchestratoreTris
INIZIO

    giocatore_corrente = 1 // Inizia sempre il giocatore 1 
    partita_in_corso = VERO

    // Ciclo principale di gioco 
    while partita_in_corso È VERO ESEGUE:
        
        mossa_valida = FALSO
        REGISTRA mossa_scelta = 0

        // Ciclo di Input e Controllo 
        while mossa_valida È FALSO ESEGUE:
            
           // 5. Passaggio del Turno 
            if giocatore_corrente == 1 then
                giocatore_corrente = 2
            else
                giocatore_corrente = 1
            FINE if
            
            // 1. Input Utente
            mossa_scelta = RICHIEDI_INPUT da giocatore 1 (valore da 1 a 9)
            
            // 2. Controllo Stato Cella 
            if file_stato[mossa_scelta] È VUOTO then
                mossa_valida = VERO
            else
                INVIA "Casella occupata, riprova!" a container_giocatore[giocatore_corrente]
            FINE if
            
        FINE while

        // 3. Aggiornamento Stato 
        SCRIVI container_giocatore[giocatore_corrente].SIMBOLO dentro file_stato[mossa_scelta]

        // Metti in attesa il giocatore che ha appena mosso 
        DISATTIVA container_giocatore[giocatore_corrente]

        // 4. Verifica Condizioni fine partita 
        // Mappatura dello stato corrente in un array locale per il controllo 
        for i DA 1 A 9 ESEGUE:
            griglia[i] = LEGGI file_stato[i]
        FINE for

        // Controllo combinazioni vincenti 
        if (griglia[1]==griglia[2]==griglia[3] non vuote) OPPURE
           (griglia[4]==griglia[5]==griglia[6] non vuote) OPPURE
           (griglia[7]==griglia[8]==griglia[9] non vuote) OPPURE
           (griglia[1]==griglia[4]==griglia[7] non vuote) OPPURE
           (griglia[2]==griglia[5]==griglia[8] non vuote) OPPURE
           (griglia[3]==griglia[6]==griglia[9] non vuote) OPPURE
           (griglia[1]==griglia[5]==griglia[9] non vuote) OPPURE
           (griglia[3]==griglia[5]==griglia[7] non vuote) then
            
            STAMPA "Il Giocatore " + giocatore_corrente + " ha vinto la partita!"
            partita_in_corso = FALSO

        // Controllo Pareggio
        else (tutti i file_stato da 1 a 9 NON sono vuoti) then
            STAMPA "La partita è finita in pareggio!"
            partita_in_corso = FALSO
            
        
        FINE if

    FINE while



FINE


