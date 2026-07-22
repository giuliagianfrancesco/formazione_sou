# EXERCISE: Ansible Vault

## GOAL:
Create a Vault Ansible for secret variables and use it in a playbook to print them.


## 1. Create Vault

Create encrypted file with command:

```bash
ansible-vault create /etc/ansible/vault_pass.yml
```

It requires a password to protect file.

Insert the variables as an key-value list:

```yaml
password: SuperSegreta123
mysecret: ValoreNascosto
```


## 2. Playbook

File `playbook.yml` includes variables in the `vars_files` field and print them with shell module:

```yaml
- hosts: localhost
  vars_files:
    - /etc/ansible/vault_pass.yml

  tasks:
    - name: Stampa valori vault
      shell: echo "{{ item }}"
      loop:
        - "{{ password }}"
        - "{{ mysecret }}"
```

## 3. Execution

Since the file is encrypted, it is necessary to specify to Ansible the password Vault through the flag  `--ask-vault-pass`:

```bash
ansible-playbook playbook.yml --ask-vault-pass
```


## Commands to encrypt and decrypt password file and other useful command

| comando | descrizione |
|---|---|
| `ansible-vault create file.yml` | Create a new encrypt file |
| `ansible-vault edit file.yml` | Edit an existing file |
| `ansible-vault view file.yml` | Access file in mode Read-Only |
| `ansible-vault decrypt file.yml` | decrypt file |
| `ansible-vault encrypt file.yml` | Encrypt file |


