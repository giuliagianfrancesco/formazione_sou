# EXERCISE: Jinja2 Templates for Dockerfile Parameterization

## GOAL

Parameterize a Dockerfile using Jinja2 templating.

## 1. Template Jinja2 (`config.j2`)

The Dockerfile is written as a Jinja2 template, using variables for the base image and working directory. This is useful to have a template that can be easily reused for other values of the variables.

## 2. Playbook

Variables (`vars`):
  - `so`: base image used in the `FROM` instruction 
  - `dir`: working directory used in `WORKDIR` and `COPY` instructions 

Module Ansible: `ansible.builtin.template`

Parameters:
  - `src`: path of the Jinja2-formatted template (`config.j2`).
  - `dest`: location where the rendered Dockerfile is written (`dockerfile`).

