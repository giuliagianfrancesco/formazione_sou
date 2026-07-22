#!/bin/bash

# Dichiarazione dei due array dichiarativi server-num_ricorrenze server-cpu_usata
declare -A count_ser
declare -A cpu_totale


# ciclo su ogni riga del file passato con < "$1" e dividendo nelle due variabili server e cpu
while read -r server cpu; do

    # calcolo cpu totale usata e ricorrenza server 
    cpu_totale["$server"]=$(( cpu_totale["$server"] + cpu ))
    count_ser["$server"]=$(( count_ser["$server"] + 1 ))

done < "$1"

# ciclo sui 4 server
for server in "${!cpu_totale[@]}"; do
    # calcolo e stampo la media
    media=$(( ${cpu_totale["$server"]} / ${count_ser["$server"]} ))
    echo "Il server: $server ha un consumo medio di: $media%"
done

~                                                                                               
~     
