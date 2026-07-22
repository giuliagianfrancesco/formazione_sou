# EXERCISE: Ansible Jinja2 Templates - Whitelist Access

## GOAL

Solve exercise on managing an Ansible playbook with Jinja2 templates.

Suppose the file `/etc/security/access.conf` has a last line that denies access to
all users not authorized (`- : ALL : ALL`).

File `playbook_access.yml`: adds a list of users , inserted before
that line, using Jinja2 templating to generate the list dynamically.

## 1. Template Jinja2 (`config_acc.j2`)

The Jinja2 template generates a whitelist to authorize user, iterating over the
`utenti_wl` list:

```jinja2
{% for u in utenti_wl %}
{{ u }} : ALL
{% endfor %}
```

## 2. Playbook


Module Ansible: `ansible.builtin.template`

Parameters:
  - src: Path of a Jinja2 formatted template on the Ansible controller.
  - dest: Location to render the template to on the remote machine 

Module Ansible: `ansible.builtin.blockinfile`

Parameters:
  - path:  The file to modify.
  - block:  The text to insert inside the marker lines.
  - insertbefore: inserts the block before the line matching the given
    pattern (in this case, before the `- : ALL : ALL` line).

Keyword:
  - lookup: reads the content of the file generated from the Jinja2 template and
    inserts it it in a text block.


