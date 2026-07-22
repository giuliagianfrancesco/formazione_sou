# Backup e Restore MariaDB — 3 metodi

## Obiettivo

Automatizzare backup e restore di un database MariaDB tra due VM (`vm1` , `vm2`) usando `mariadb-backup`. 
Realizzato seguendo tre metodi:
- Metodo manuale usando linguaggio SQL  
- Metodo automatizzato con Ansible
- Metodo automatizzato tramite AWX


## Metodo 1 - Manuale

Procedura eseguita su vm1/vm2 costruite utilizzando `Vagrantfile`, con Rocky Linux assegnando IP statici.

### Su vm1 e vm2 -Installazione e avvio Mariadb

```bash
sudo dnf makecache
sudo dnf install mariadb
systemctl enable mariadb
systemctl start mariadb
```
### Su vm1 — Creazione dati di test

```sql
CREATE DATABASE azienda;
USE azienda;
CREATE TABLE dipendenti (
  dipendente_id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(15),
  cognome VARCHAR(20),
  mansione VARCHAR(50)
);
INSERT INTO dipendenti (nome, cognome, mansione) VALUES
  ('Giulia', 'Gianfrancesco', 'stagista'),
  ('Mario', 'Rossi', 'manager'),
  ('Pippo', 'Pippo', 'apprendista');
```

### Su vm1 — Backup fisico con mariadb-backup

```bash
mariadb-backup --backup \ # Avvia il backup fisico
  --target-dir=/var/mariadb/backup/ \ # Specifica la cartella in cui salvare i file
  --user=mariadb-backup --password=mypassword # Nome dell'utente e password con privilegi di backup
```

### Trasferisci il backup da vm1 a vm2

```bash
scp -i .vagrant/machines/vm1/virtualbox/private_key -r \   # Avvia la copia sicura tramite protocollo SSH specificando chiave (-i) copiando in modo ricorsivo (-r) 
  /var/mariadb/backup vagrant@192.168.56.12:/var/mariadb/ # Percorso della cartella di backup su VM1 e destinazione tramite utente, IP, path cartella
```

### Su vm2 — Ripristino

```bash
ls /var/mariadb/backup/         # per verificare che sia stato effettivamente riempito

mariadb-backup --prepare --target-dir=/var/mariadb/backup/ # Applica le transazioni rimaste in sospeso
mkdir /var/lib/mysql
mariadb-backup --copy-back --target-dir=/var/mariadb/backup/  # Copia i file del backup preparato nella cartella
chown -R mysql:mysql /var/lib/mysql # Cambia propretario e gruppo dei file ripristinati

```

### Verifica su vm2

```sql
SHOW DATABASES;
USE azienda;
SHOW TABLES;
SELECT * FROM dipendenti;
```

Risultato: la tabella `dipendenti` con le 3 righe inserite su vm1 è presente anche su vm2.

---

## Versione automatizzata con Playbook

### Ambiente

- 2 VM Vagrant, Rocky Linux
- `hosts.ini` con IP host (`192.168.56.11` / `192.168.56.12`)
- Chiavi SSH generate automaticamente da Vagrant
- Passaggi equivalenti a quelli manuali ma usando moduli Ansible

### Moduli usati

- `dnf` — installazione pacchetti (PyMySQL, MariaDB-server/client/backup)
- `yum_repository` — aggiunta repo ufficiale MariaDB
- `ansible.builtin.service` — avvio/enable servizio mariadb
- `community.mysql.mysql_db` / `mysql_query` — creazione DB e query
- `ansible.builtin.command` — per esecuzione backup e restore
- `ansible.builtin.archive` / `unarchive` — compressione/estrazione backup
- `ansible.builtin.fetch` / `copy` — trasferimento backup tra vm1 e vm2
:w

### Parametri group_vars/all/vars.yml group_vars/vault/vault.yml 

- `mariadb_version` — versione MariaDB
- `vault_mariadb_backup_password` — password DB, cifrata con Ansible Vault

---


## Versione Playbook (locale, Vagrant)

### Ambiente

- 2 VM Vagrant (VirtualBox), Rocky Linux
- `hosts.ini` con IP host-only (`192.168.56.11` / `192.168.56.12`)
- Chiavi SSH generate automaticamente da Vagrant

### Moduli usati

- `dnf` — installazione pacchetti (PyMySQL, MariaDB-server/client/backup)
- `yum_repository` — aggiunta repo ufficiale MariaDB
- `ansible.builtin.service` — avvio/enable servizio mariadb
- `community.mysql.mysql_db` / `mysql_query` — creazione DB e query
- `ansible.builtin.command` — esecuzione `mariadb-backup --backup` / `--prepare`
- `ansible.builtin.archive` / `unarchive` — compressione/estrazione backup
- `ansible.builtin.fetch` / `copy` — trasferimento backup tra vm1 e vm2

### Parametri chiave

- `mariadb_version` — versione MariaDB
- `vault_mariadb_backup_password` — password DB, cifrata con Ansible Vault

### Comando di esecuzione

```bash
ansible-playbook -i backupMariadb/hosts.ini backupMariadb/playbook.yml --ask-vault-pass
```

### Keyword

- **mariadb-backup**: tool fisico di backup MariaDB (diverso da `mysqldump`, copia i file a livello di storage engine)
- **Vault**: meccanismo Ansible per cifrare variabili sensibili (qui la password DB)

---

## Installazione AWX (Colima + Minikube)

### 1. Avvio Colima con risorse sufficienti per AWX

```bash
colima start --cpu 3 --memory 5.5 --mount-type virtiofs
```

### 2. Avvio Minikube sopra Colima

```bash
minikube start --cpus=3 --memory=5120 --driver=docker
kubectl config use-context minikube
kubectl get nodes
```

### 3. Creazione del namespace AWX

```bash
kubectl create namespace awx
```

### 4. Manifest di awx-operator in modo customizzato

```bash
mkdir awx-operator-install && cd awx-operator-install

cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - github.com/ansible/awx-operator/config/default?ref=2.19.1
images:
  - name: quay.io/ansible/awx-operator
    newTag: 2.19.1
  - name: gcr.io/kubebuilder/kube-rbac-proxy
    newName: quay.io/brancz/kube-rbac-proxy
    newTag: v0.15.0
namespace: awx
EOF
kubectl apply -k .
kubectl get pods -n awx -w
```
## 5. Istanza AWX

```bash
cat <<EOF > awx-demo.yml
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
  namespace: awx
spec:
  service_type: nodeport
  nodeport_port: 30080
EOF
kubectl apply -f awx-demo.yml -n awx
kubectl get pods -n awx -w

```

### 6. Accedi all'interfaccia via port-forward

```bash
kubectl port-forward service/awx-demo-service -n awx 8013:80
```
Username di default: 
`admin`

Recupero password:
```bash
kubectl get secret awx-demo-admin-password -n awx -o jsonpath="{.data.password}" | base64 --decode; echo
```

### Keyword

- **AWX Operator**: componente Kubernetes che gestisce AWX
- **Kustomize**: strumento di gestione manifest Kubernetes usato per personalizzare il deploy dell'operator (per impostare versione)
- **NodePort**: usato con `port-forward` per esporre AWX fuori dal cluster

---

### Setup AWX 

1. **Project**: collegato al repo Git (`formazione_sou`)
2. **Credentials**:
   - *Machine*: user `vagrant`, chiave privata `awx_vagrant_key`, escalation `sudo`
   - *Vault*: password usata per cifrare `vault_mariadb_backup_password`
3. **Inventory**: Source "Sourced from a Project" con `backupMariadb/hosts.ini` dal repository
4. **Job Template**: Playbook `backupMariadb/playbook.yml`, Inventory + Project + le Credentials

### Variazioni con struttura playbook Ansible: 

  - Aggiunto `requirements.yml` in `formazione_sou` per collezioni necessarie a esecuzione playbook
  - Variabili cifrate spostate in vars perchè l'inventory di AWX legge automaticamente `group_vars/` oltre a `hosts.ini`, ma non vede Vault Credential (solo in Job Template), quindi fallisce.
  -  Nel file `hosts.ini` ho rimosso nsible_ssh_private_key_file=.vagrant/machines/vmX/virtualbox/private_key (path locale che AWX non troverebbe)
  - Ho generato una chiave SSH dedicata (awx_vagrant_key) e l'ho aggiunta a ~/.ssh/authorized_keys su vm1 e vm2 e l'ho aggiunte su AWX tramite credential: Machine.

  - Nel file `hosts.ini` hoaggiunto ansible_port con porta SSH della VM.








