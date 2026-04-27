Lo script stampa i parametri forniti dall'utente al momento che lo esegue. 
Stampa prima il nome dello script con $0 e il nome del path. 



Stampa poi i valori inseriti (usando $n o ${n} nel caso di valori a piu cifre) per ciascun parametro inserito, controllando che siano non nulli con if e -n.Stampa tutti i valori passati con ($*). Prende poi il numero di tutti i numeri inseriti  ($#) e controlla che siano almeno 10 (ls: less than). Se non lo sono stampa l'errore all'utente. 
