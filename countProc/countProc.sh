#!/bin/bash

numPIDmax=$2
numPIDmin=$1
exitCode=0 

if [ "$1" -gt "$2" ]; then
   let exitCode=exitCode+2

fi
declare -A count
count[S]=0
count[Z]=0
count[R]=0
count[D]=0
count[T]=0
count[I]=0

checkStatus() {
s=$1
if [ "$s" == "S" ]; then
    let count[S]=count[S]+1

fi
if [ "$s" == "Z" ]; then
    let count[Z]=count[Z]+1

fi
if [ "$s" == "D" ]; then
    let count[D]=count[D]+1

fi
if [ "$s" == "R" ]; then
    let count[R]=count[R]+1

fi
if [ "$s" == "T" ]; then
    let count[T]=count[T]+1

fi
if [ "$s" == "I" ]; then
    let count[I]=count[I]+1

fi

}

findStatus() {
    p=$1
    ps u -p $p > file.txt
    var=$(awk 'NR==2 {print $8}' file.txt)
    var=${var:0:1}

}

proc=$numPIDmin
while [ "$proc" -le "$numPIDmax" ]
do

    status=$(findStatus $proc)
    ps u -p $p
    res=$?
    if [ $res -eq 0 ]; then

        checkStatus "$status"
    else
        exitCode=$exitCode+$((exitCode + res))

    fi
    ((proc++))
done

echo "S: ${count[S]} | Z: ${count[Z]} | R: ${count[R]} | D: ${count[D]} | T: ${count[T]}, | I: ${count[I]}"
exit $exitCode
