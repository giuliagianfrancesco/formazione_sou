
Lo script si muove nella cartella dei Log, dove troviamo i file che contengono le informazioni sullo stato del sistema, dei processi e di eventuali errori.

cat: per scrivere sul file
/dev/null : dispositivo virtuale che scarta tutto ciò che gli viene passato in input
> : serve ad reindirizzare l’output del comando nel file specificato subito dopo.

Dunque la seconda e la terza riga dello script servono a sostituire il contenuto di messages e wtmp (dove nel primo si tiene traccia di informazioni sui processi e sul sistema e nel secondo si tiene traccia di login/logout/reboot ecc).

Infine con echo stampa su terminale la conferma che i file log sono stati puliti.
