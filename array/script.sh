#!/bin/bash

stringa=$(echo "$1" | tr '[:upper:]' '[:lower:]')

read -r -a array <<< "$stringa"

echo "${array[*]}"

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

array_nodup=()
for ((i=0; i<$n; i++)); do
    if (( i == 0 )); then
    	array_nodup+=("${array[i]}")
    elif [[ "${array[i]}" != "${array[i-1]}" ]]; then
    

        array_nodup+=("${array[i]}")
    fi
done

echo "${array[*]}"
echo "${array_nodup[*]}"
