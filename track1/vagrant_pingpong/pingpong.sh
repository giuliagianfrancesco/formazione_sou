#!/bin/bash
VM=$(hostname)
FILE="/vagrant/turno.txt"



while true; do
    TURNO=$(cat "$FILE")

    if [ "$TURNO" == "$VM" ]; then
	sudo docker rm -f echo-server > /dev/null 2>&1
        echo " è il turno di [$VM]"
        sudo docker run --name echo-server -d -p 3000:80 ealen/echo-server:0.9.2
        
        sleep 60
        
        echo "[$VM] Il minuto è scaduto"
        
	sudo docker rm -f echo-server > /dev/null 2>&1        
        if [ "$VM" == "vm1" ]; then
            echo -n "vm2" > "$FILE"
        else
            echo -n "vm1" > "$FILE"
        fi
    fi 
    sleep 2
done
