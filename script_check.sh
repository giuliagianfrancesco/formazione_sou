
#!/bin/bash

yaml_file="flask-deployment-export.yaml"



containers=$(kubectl get -f "$yaml_file" -o jsonpath='{.spec.template.spec.containers[*].name}')

for container in $containers; do
    BASE="{.spec.template.spec.containers[?(@.name==\"$container\")]}"
    liveness=$(kubectl get -f "$yaml_file" -o jsonpath="${BASE}.livenessProbe")
    readiness=$(kubectl get -f "$yaml_file" -o jsonpath="${BASE}.readinessProbe")
    limits=$(kubectl get -f "$yaml_file" -o jsonpath="${BASE}.resources.limits")
    requests=$(kubectl get -f "$yaml_file" -o jsonpath="${BASE}.resources.requests")
    
    if [ -z "$liveness" ] || [ -z "$readiness" ]|| [ -z "$limits" ] || [ -z "$requests" ]; then
        exit 1

    fi
    
    

done


