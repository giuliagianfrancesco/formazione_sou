# Port Scanner Bash Script

Questo repository contiene uno script Bash per scansionare un intervallo di porte TCP su un indirizzo IP specifico.

Descrizione
Lo script automatizza il controllo delle porte utilizzando l'utility `nc` (netcat). Prima di eseguire la scansione, effettua diversi controlli:
1. Controlla che siano stati passati esattamente 3 parametri.
2. Controlla che il range delle porte sia compreso tra 1024 e 49151.
3. Controlla l'indirizzo IP controllando che ogni ottetto sia compreso tra 0 e 255.

Requisiti
Assicurati di avere `netcat` installato sul tuo sistema Linux/Unix.
```bash
# Esempio su Ubuntu/Debian
sudo apt-get install netcat-openbsd
