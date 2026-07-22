Lo script mostra diversi modi di assegnazione di una variabile.
Inizia da una prima assegnazione (semplicemente a=879) e la stampa poi a schermo con $a. 
Il dollaro permette di vedere il contenuto della variabile a.

Dopo usa let per assegnare ad "a" il risultato di un espressione (senza let "a" sarebbe uguale a 16+5 e non 21. Stampa poi come prima il valore di "a".

Stampa poi i valori della variabile "a" che vengono assegnati ad essa in un ciclo for echo -n consente di non aggiungere il carattere di a capo e quindi stampa tutto su una riga. "a" assumerà un valore diverso (7 8 9 11) ad ogni iterazione del for.

Infine nell'ultima assegnazione usa read "a" per leggere valore da assegnare direttamente da tastiera, cosi da permettere all'utente di inserire un valore che verrà poi installato.

Restituisce exit code uguale a 0 per consentire la corretta uscita dallo script con code che indica assenza di errori nel codice.

  
