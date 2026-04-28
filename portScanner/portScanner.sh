#!/usr/bin/env bash
MIN=3
if [ $# -ne "$MIN" ]; then
    echo "i parametri devono essere 3"
    exit 1;
fi
if [ $2 -lt 1024 ] || [ $3 -gt 49151 ]; then
    echo "range porta non valido"
    exit 1;
fi

IFS='.' read -r -a ott <<< "$1"
numOtt=0
while [ ${numOtt} -le 3 ]
do
    if [ -z ${$ott[3]} ]; then
        echo "ip errato"
        exit 1;
    fi

    if [ ${ott[j]} -gt 255 ] || [ ${ott[j]} -lt 0 ]; then
        echo "ip errato"
        exit 1;
    fi

    let numOtt=numOtt+1
done

numPorta=$2
touch file.txt

while [ ${numPorta} -le $3 ]
do
    nc -v -w 1 $1 ${numPorta} > file.txt 2>&1
    if grep -q "succeed" file.txt; then
        echo "porta connessa ${numPorta}"
    fi
    let numPorta=numPorta+1
done
