La prima parte dello script è contenuta in un ciclo while (che termina quando arriva il segnale di exit) eseguito in background (& alla fine del blocco while)
Il comando di trap prima del blocco while serve a terminare il ciclo quando riceve un segnale SIGUSR1 per forzare l'uscita del processo. 
Nel while si costruisce una progress bar costituita da punti che vengono stampati ogni secondo ($interval) senza andare a capo grazie opzione -n di echo.


Lo script cattura poi il pid dell'ultimo processo in background. 


Stampa "long-running process" e attende 10 secondi ($long_interval) prima di stampare "Fimished".

Infine interrompe il processo con pid salvato in precedenza, attende la chiusura completa del processo, cattura e restituisce exit code per segnalare eventuali errori. 
