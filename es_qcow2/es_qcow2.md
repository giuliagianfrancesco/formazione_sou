
## Panoramica generale 

QCOW2 (QEMU Copy On Write) è un formato di disk image per macchine virtuali, ovvero un file che rappresenta un intero disco virtuale con le sue partizioni, il filesystem, il bootloader ecc. È utilizzato come se fosse un disco fisico collegato a una macchina virtuale. Viene spesso usato con macchine virtuali avviate con QEMU/KVM.

I principali vantaggi di usare questo formato rispetto ad altri sono: 

- L’utilizzo efficiente della memoria, riducendo lo spazio utilizzato. I file QCOW2 non occupano l’intera dimensione virtuale sul disco fisico ma solo lo spazio effettivamente usato e adegua la dimensione dinamicamente in base ai dati successivamente scritti.
- Si possono creare immagini custom, a partire da un’immagine di base, che salvano in uno snapshot lo stato della macchina. Questo rende la creazione di snapshot rapida e con poco consumo di spazio.
- Ripetibilità e testing potendo creare nuove immagini senza contaminare immagine di partenza

L’approccio è quello di utilizzare un’immagine di partenza che sia in formato qcow2 che diventerà il nostro backing file. Questa verrà utilizzata come riferimento per le immagine successive costruite da questa. In particolare, solamente le modifiche all’immagine di partenza che vengono effettuate verranno salvate in un overlay file.
L'overlay è il nuovo file (```overlay.qcow2``` nell'esempio) che punta al backing file. Contiene solo le differenze rispetto alla base:
* Se leggi un blocco che non è mai stato modificato viene letto dal backing file
* Se viene modificato qualcosa il blocco modificato viene salvato nell'overlay, non nella base, che resta sempre uguale.

Comando per generare overlay:

```
qemu-img create -f qcow2 -b base.qcow2 -F qcow2 overlay.qcow2
```




Comandi QEMU utili per gestire e ispezionare immagine:
```
qemu-img info immagine.qcow2
``` 

Mostra il formato, dimensione virtuale vs reale, cluster size , e se presente il backing file.

```
qemu-img check immagine.qcow2
``` 

Controlla che l'immagine non sia corrotta (utile dopo operazioni con virt-customize/guestfish)

``` 
qemu-img create -f qcow2 nuova-immagine.qcow2 10G
``` 

Crea un disco vuoto da 10 GB (occupa poco spazio finché non vengono scritti dati).

```
qemu-img resize immagine.qcow2 +10G
``` 
Aumenta lo spazio virtuale di 10 GB 


## Ambiente e strumenti utilizzati
- Immagine di partenza: Ubuntu cloud image ufficiale (formato qcow2), scaricata da cloud-images.ubuntu.com 

- Strumenti scaricati: virt-customize e guestfish (pacchetto libguestfs-tools) entrambi gli strumenti operano modificando il filesystem dell'immagine senza avviare la macchina virtuale



## Approccio interattivo

La modalità interattiva prevede l’utilizzo di una shell in cui possiamo scrivere dei comandi manualmente.

```
guestfish -a mia-immagine.qcow2 -i 
```

Questo comando apre un prompt (><fs>) all'interno del quale i comandi vengono inseriti a mano:
```
><fs> 
```

Per modificare la password di root si opera sulla riga corrispondente in /etc/shadow, che contiene un hash con salt:
```
root:$6$saltcasuale$hashcalcolato…:…
```

In modalità interattiva si deve:
1. Generare manualmente l'hash (openssl passwd -6) fuori da guestfish
2. Aprire shell interattiva con guestfish
3. Trovare l'intera riga (con comando sed-i)
4. Riscriverla nel file
```
><fs> cat /etc/shadow 
><fs> sed-i 's|^root:[^:]*:|root:nuovapassword…:|’ /etc/shadow
><fs> cat/etc/shadow
><fs> exit
```

Non in tutte le versioni di guestfish c’è sed-i, si può usare anche:
```
Write nome_file  contenuto_identico_con_nuova_password
```

Comando write sovrascrive interamente il file, quindi bisogna inserire il contenuto di tutto il file non solo la parte relativa a root.

La modalità interattiva non è ripetibile né automatizzabile: ogni esecuzione richiede operatore umano, rendendola inadatta a strumenti di automazione e approcci pratici su larga scala.

## Approccio scriptato

La modalità scriptata prevede l'esecuzione di un comando (o script) completo, senza alcuna interazione umana durante l'esecuzione: tutti i parametri sono forniti in anticipo.

virt-customize ha un'opzione che gestisce internamente la generazione dell'hash e la sostituzione corretta della riga in /etc/shadow:
```
bash
#!/bin/bash

IMG_SRC="noble-server-cloudimg-amd64.img"
IMG_OUT="mia-immagine.qcow2"

cp "$IMG_SRC" "$IMG_OUT"
```
```
virt-customize -a "$IMG_OUT" --root-password password:'MiaNuovaPassword'
```

Questo comando:
   - Non richiede alcun input durante l'esecuzione
   - Genera automaticamente l'hash della password nel formato corretto 
   - Sostituisce la riga di root in /etc/shadow in modo sicuro-
   - È riproducibile ed eseguibile da script e in ambienti automatizzati


Per ripetibilità, utilizzo su larga scala, integrazione in pipeline o tool di automazioni e la non necessità di intervento umano questo approccio è il più funzionale.
