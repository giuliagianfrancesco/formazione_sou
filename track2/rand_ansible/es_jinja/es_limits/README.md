# EXERCISE: Ansible Jinja2 Templates

## GOAL

Solve exercise on managing Ansible playbook with Jinja Templates

File `playbook_jinja.yml`: Add max number open files limits (`nofile`) based on environment in the file: `/etc/security/limits.conf`
using Jinja2 templating for the if/else logic:
    - **produzione** → limite 10000
    - **sviluppo / collaudo** → limite 1000


## 1. Template Jinja2 (`config.j2`)

Template Jinja2 generates automatically the value based on the environment: 

```jinja2
{% if ambiente == 'produzione' %}
10000
{% elif ambiente == 'sviluppo' or ambiente == 'collaudo' %}
1000
{% endif %}
```

## 2. Playbook

Module Ansible: `ansible.builtin.template`

Parameter:
  - src: Path of a Jinja2 formatted template on the Ansible controller.

  - dest: Location to render the template to on the remote machine 

Module Ansible: `ansible.builtin.blockinfile`

Parameter:
  - path:  The file to modify.
  - block:  The text to insert inside the marker lines.
  - insertafter: EOF inserting the block at the end of the file.
  - create: yes Create a new file if it does not exist.

Keyword: 
  - lookup: read the content of the file generated starting from Jinja2 template and insert it in a block of test

## Execution

To test in the different environment, used the flag `--extra-vars` (`produzione`, `sviluppo`, `collaudo`)

```bash
ansible-playbook playbook_jinja.yml --extra-vars  "ambiente=sviluppo"
```
