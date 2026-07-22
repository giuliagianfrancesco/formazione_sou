# Kubernetes Esercizio: Gestione dei Secret 

## Obiettivi dell'Esercizio
1. Creare un Secret contenente `user` e `password` tramite CLI con l'opzione `--from-literal`
2. Visualizzare il Secret in formato YAML
3. Modificare YAML utilizzando nuove credenziali codificate in Base64 per generare un secondo Secret
4. Creare un Pod che utilizzi queste variabili d'ambiente
5. Verificare finale eseguendo un `echo` all'interno del Pod


Per creare il primo Secret (chiamato `creds`) direttamente dalla riga di comando usa `kubectl create`

```
 kubectl create secret generic creds --from-literal user=mio_user --from-literal pwd=mia_password
```

Ho estratto lo YAML con:

```
kubectl get secret creds -o yaml
```

Ho modificato lo YAML con nuove credenziali codificate:

```
echo -n "mio_user" | base64
echo -n "mia_password" | base64
```
Ho creato un Pod:

kubectl apply -f secretpod.yml

Dove ho inserito le credenziali come variabili d'ambiente:

```
...
env:
    - name: secUser
      valueFrom:
        secretKeyRef:
          name: creds
          key: user
    - name: secPass
      valueFrom:
        secretKeyRef:
          name: creds
          key: pwd
```


Test all'interno del Pod:

```
kubectl exec -it secretpod -- /bin/bash
echo $secUser
echo $secPass
```
