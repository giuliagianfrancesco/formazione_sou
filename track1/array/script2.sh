#!/bin/bash

stringa=$(echo "$1" | tr '[:upper:]' '[:lower:]')

declare -A arraydic
for parola in $stringa; do
    arraydic["$parola"]=1
done

array=("${!arraydic[@]}")
n=${#array[@]}

for ((i=0; i<$n; i++)); do
    for ((j=i+1; j<$n; j++)); do
        if [[ "${array[i]}" > "${array[j]}" ]]; then
            temp=${array[i]}
            array[i]=${array[j]}
            array[j]=$temp
        fi
    done
done

echo "${array[*]}"
