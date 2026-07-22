# EXERCISE: Ansible Dictionaries and lists

## GOAL:

Solves two exercises managing lists and dictionaries in a playbook:

- EX1 : File ` playbook_apt.yml` : installs/disinstalls  a list of packages defined in a dictionary in the ` vars`  field of playbook
- EX2 : File ` playbook_user.yml`  Creates a list of users with own features based on a dictionary defined in the ` vars`  field of the playbook

## 1. Playbook EX1

Install/Uninstall packages defined in a dictionary using Jinja2 templating to use the dictionary elements in the task, syntax: "{{ elem }}"

Module Ansible: ` ansible.builtin.apt`         

Parameter:
  - `update_cache` is a parameter of apt module which runs the equivalent of apt-get update before the operation.
  - `state:  present` packages are installed if not present (idempotent)
  -`state: absent` packages are uninstalled if present (idempotent)

Keywords:
  - `loop`: to iterate on a lists of object
  - `dict2items`: to create an iterable list of objects starting from a dictionary


## 2. Playbook EX2

Creates a list of users with own features based on a lists of dictionaries using Jinja2 templating, syntax: "{{ elem.feature }}"

Module Ansible: ` ansible.builtin.user`

Parameter:
  - `name`: name new user
  - `shell`: default shell used
  - `groups`: group to which add new user
  - `create_home`: yes to create user home
  - `home`: path user home
Keywords:
  - `loop` : to iterate on a lists of objects
