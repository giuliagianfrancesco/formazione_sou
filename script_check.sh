
#!/bin/bash

yaml_file="flask-deployment-export.yaml"



containers=$(kubectl get -f "$yaml_file" \
  --token="$SERV_ACC" \
  --server="https://192.168.64.2:8443" \
  --insecure-skip-tls-verify=true \
  -o jsonpath='{.spec.template.spec.containers[*].name}')
  
for container in $containers; do
    BASE="{.spec.template.spec.containers[?(@.name==\"$container\")]}"
    liveness=$(kubectl get -f "$yaml_file"  \
  --token="$SERV_ACC" \
  --server="https://192.168.64.2:8443" \
  --insecure-skip-tls-verify=true \
  -o jsonpath="${BASE}.livenessProbe")
    readiness=$(kubectl get -f "$yaml_file" \
  --token="$SERV_ACC" \
  --server="https://192.168.64.2:8443" \
  --insecure-skip-tls-verify=true \
    -o jsonpath="${BASE}.readinessProbe")
    limits=$(kubectl get -f "$yaml_file" \
  --token="$SERV_ACC" \
  --server="https://192.168.64.2:8443" \
  --insecure-skip-tls-verify=true \
  -o jsonpath="${BASE}.resources.limits")
    requests=$(kubectl get -f "$yaml_file"  \
  --token="$SERV_ACC" \
  --server="https://192.168.64.2:8443" \
  --insecure-skip-tls-verify=true \
  -o jsonpath="${BASE}.resources.requests")
    
    if [ -z "$liveness" ] || [ -z "$readiness" ]|| [ -z "$limits" ] || [ -z "$requests" ]; then
        exit 1

    else
        echo "Container $container ha livenessProbe, readinessProbe, resource limits e resource requests configurati."
    fi
    

done


