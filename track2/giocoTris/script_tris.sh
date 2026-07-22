#!/bin/bash
num_g=2 
gioco_non_finito=true 
simbolo=("X" "O")
array=(" " " " " " " " " " " " " " " " " ") 
mosse=0 
for i in {1..9}; do
    sudo docker exec cas_"$i" /bin/sh -c "echo ' ' > /cas_${i}.txt"
done
condizione_vittoria(){
    if [[ "${array[0]}" != " " && "${array[0]}" == "${array[1]}" && "${array[1]}" == "${array[2]}" ]]; then
        echo "Il giocatore $num_g (${simbolo[num_g-1]}) ha vinto!"
        gioco_non_finito=false
    elif [[ "${array[3]}" != " " && "${array[3]}" == "${array[4]}" && "${array[4]}" == "${array[5]}" ]]; then
        echo "Il giocatore $num_g (${simbolo[num_g-1]}) ha vinto!"
        gioco_non_finito=false
    elif [[ "${array[6]}" != " " && "${array[6]}" == "${array[7]}" && "${array[7]}" == "${array[8]}" ]]; then
        echo "Il giocatore $num_g (${simbolo[num_g-1]}) ha vinto!"
        gioco_non_finito=false
    elif [[ "${array[0]}" != " " && "${array[0]}" == "${array[3]}" && "${array[3]}" == "${array[6]}" ]]; then
        echo "Il giocatore $num_g (${simbolo[num_g-1]}) ha vinto!"
        gioco_non_finito=false
    elif [[ "${array[1]}" != " " && "${array[1]}" == "${array[4]}" && "${array[4]}" == "${array[7]}" ]]; then
        echo "Il giocatore $num_g (${simbolo[num_g-1]}) ha vinto!"
        gioco_non_finito=false
    elif [[ "${array[2]}" != " " && "${array[2]}" == "${array[5]}" && "${array[5]}" == "${array[8]}" ]]; then
        echo "Il giocatore $num_g (${simbolo[num_g-1]}) ha vinto!"
        gioco_non_finito=false
    elif [[ "${array[0]}" != " " && "${array[0]}" == "${array[4]}" && "${array[4]}" == "${array[8]}" ]]; then
        echo "Il giocatore $num_g (${simbolo[num_g-1]}) ha vinto!"
        gioco_non_finito=false
    elif [[ "${array[2]}" != " " && "${array[2]}" == "${array[4]}" && "${array[2]}" == "${array[6]}" ]]; then
        echo "Il giocatore $num_g (${simbolo[num_g-1]}) ha vinto!"
        gioco_non_finito=false
    fi
    if [[ $mosse -ge 9 && $gioco_non_finito == true ]]; then
        echo "Tutte le caselle sono già occupate, La partita è finita in pareggio!"
        gioco_non_finito=false
    fi
}

while [[ $gioco_non_finito == true ]]; do # Ciclo dei turni
   
    if [[ $num_g -eq 1 ]]; then num_g=2; else num_g=1; fi 
    
    echo -e "\nTurno Giocatore $num_g con simbolo: (${simbolo[num_g-1]})"
   
    while true; do # Ciclo di inserimento casella 
        
        read -p "Inserisci un numero da 1 a 9 per selezionare una casella: " mossa
        
        # Controlla se la casella è vuota o già scritta
        stato_casella=$(sudo docker exec cas_"$mossa" cat /cas_"$mossa".txt 2>/dev/null)
        if [[ $mossa -lt 1 || $mossa -gt 9 ]]; then
            echo "Mossa non valida"
        elif [[ "$stato_casella" == " " ]]; then 
            sudo docker exec cas_"$mossa" /bin/sh -c "echo '${simbolo[$((num_g - 1))]}' > /cas_${mossa}.txt" 
            array[$((mossa - 1))]=${simbolo[$((num_g - 1))]} 
            break # Esce dal ciclo di inserimento perché la mossa è valida
        else
            echo "La casella $mossa è già occupata, scegliere un'altra casella"
        fi
    done
    
    echo -e "\n Stampa della griglia attuale: "
    echo "${array[0]} | ${array[1]} | ${array[2]}"
    echo "----------"
    echo "${array[3]} | ${array[4]} | ${array[5]}"
    echo "----------"
    echo "${array[6]} | ${array[7]} | ${array[8]}"
    
    mosse=$((mosse + 1))
    condizione_vittoria
done

