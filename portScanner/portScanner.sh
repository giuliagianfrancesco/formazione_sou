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
j=0
while [ $j -le 3 ]
do
if [ -n ${$ott[3]} ]; then
echo "ip errato"
exit 1;
fi

if [ ${ott[j]} -gt 255 ] || [ ${ott[j]} -lt 0 ]; then
echo "ip errato"
exit 1;
fi

let j=j+1
done
i=$2
touch file.txt
while [ $i -le $3 ]
do
nc -v -w 1 $1 $i > file.txt 2>&1
if grep -q "succeed" file.txt; then
    echo "porta connessa $i"

fi
let i=i+1
done
