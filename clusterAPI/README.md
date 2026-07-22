# Cluster API — Provisioning di un cluster Kubernetes con CAPD

L'esercizio riguarda la creazione e il provisioning di un cluster Kubernetes gestito tramite Cluster API, utilizzando kind come management cluster e il provider CAPD (Docker) per il workload cluster.

## Cluster API

Cluster API è un sub-progetto di Kubernetes che fornisce API dichiarative e tool per semplificare il provisioning e la gestione di più cluster Kubernetes.

Il principio fondamentale è lo stesso della gestione di Pod e Deployment in Kubernetes: l'infrastruttura (VM, reti, load balancer) e la configurazione del cluster vengono definite in modo dichiarativo tramite custom resource, e i controller si occupano di riconciliare lo stato reale con quello desiderato.

Cluster API permette di effettuare il provisioning, lo scaling e la gestione del ciclo di vita completo di più cluster fornendo un livello di astrazione, indipendente dal provider di infrastruttura specifico.

Per Cluster API le Machine sono immutabili: una volta create, non vengono mai aggiornate ma solo sostituite. Per questo motivo `MachineDeployment` è più usato rispetto alla gestione diretta delle Machine (gestisce i cambiamenti tramite rolling replacement, così come un Deployment Kubernetes gestisce i Pod).

## Architettura: Management Cluster e Workload Cluster

Cluster API si basa su due ruoli di cluster:

**Management Cluster**
È un cluster Kubernetes di management perché in esso vengono installati i controller di Cluster API (tramite `clusterctl init`). Questi controller gestiscono le risorse (Cluster, Machine, MachineDeployment ecc) e gestiscono il provisioning.
In questo progetto uso  `kind`

**Workload Cluster**
È il cluster Kubernetes effettivo che viene creato e gestito. È un cluster con un proprio kubeconfig indipendente.
In questo progetto: `capi-quickstart`, provisionato tramite il provider Docker (CAPD).

## Creazione Management Cluster

Creare `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraMounts:
      - hostPath: /var/run/docker.sock
        containerPath: /var/run/docker.sock
```

Creazione del cluster kind:

```bash
kind create cluster --config kind-config.yaml
```

Verifica:

```bash
kubectl cluster-info --context kind-kind
```

Abilitazione flag `cluster_topology`, per gestire ClusterClass:

```bash
export CLUSTER_TOPOLOGY=true
```

## Inizializzazione di Cluster API con Docker

```bash
clusterctl init --infrastructure docker
```

Questo comando installa sul management cluster:
- il core di Cluster API
- il bootstrap provider (kubeadm) per inizializzare il control plane
- il control plane provider (kubeadm/KubeadmControlPlane)
- l'infrastructure provider Docker (CAPD) per creare le macchine/container

Verifica pod attivi:

```bash
kubectl get pods -A
```

## Provisioning del Workload Cluster

### Generazione e applicazione del manifest

```bash
# --flavor development è il flavor specifico per CAPD
clusterctl generate cluster capi-quickstart \
  --flavor development \
  --kubernetes-version v1.31.0 \
  --control-plane-machine-count=1 \
  --worker-machine-count=1 \
  > capi-quickstart.yaml

kubectl apply -f capi-quickstart.yaml
```

Estrazione del kubeconfig del workload cluster:

```bash
clusterctl get kubeconfig capi-quickstart > capi-quickstart.kubeconfig
```

## Installazione del CNI

Senza CNI, i Node restano bloccati in stato NotReady.

Installare Calico sul workload cluster:

```bash
kubectl --kubeconfig=./capi-quickstart.kubeconfig \
  apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/calico.yaml
```

## Verifica finale

```bash
# Stato dei nodi sul workload cluster
kubectl --kubeconfig=./capi-quickstart.kubeconfig get nodes

# Pod di sistema
kubectl --kubeconfig=./capi-quickstart.kubeconfig get pods -n kube-system

# Stato complessivo dal management cluster
clusterctl describe cluster capi-quickstart
```

## Deploy di un'applicazione sul Workload Cluster

Dopo aver creato un workload cluster, questo può essere usato come un cluster Kubernetes senza che Cluster API intervenga.
Ogni comando kubectl/helm va indirizzato al kubeconfig del workload cluster.

### Deploy app su Workload Cluster tramite il suo kubeconfig

```bash
export KUBECONFIG=./capi-quickstart.kubeconfig
kubectl cluster-info
```

### Deploy tramite Helm chart

Ho riutilizzato l'helm chart della track 2 per provare il deploy di un'applicazione sul cluster creato.

Creare un namespace dedicato:

```bash
kubectl create namespace formazione-sou
```

Installare la chart:

```bash
helm install formazione-sou-app ./helm-chart --namespace formazione-sou
```

Verificare lo stato:

```bash
kubectl get pods -n formazione-sou
kubectl get svc -n formazione-sou
```

## Accesso all'applicazione

Dato che il Service è di tipo ClusterIP non è raggiungibile direttamente dal Mac. Ho usato il port-forward:

```bash
kubectl port-forward svc/<nome-service-reale> 8080:80 -n formazione-sou
```

Per testare:

```bash
curl http://localhost:8080
```
