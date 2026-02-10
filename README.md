# ansible-playbooks-pedrohdz

These are my _Ansible_ playbooks for setting up my development workstations,
and more.

## Quick start

This section is meant to help you get up and running quickly — from environment
setup to running the main playbooks.

> **Warning:**  
> The file `~/.private/ansible/dev-workstation/vars/baseline.yaml` **must
> exist** before running the playbooks.  
> Use [molecule/default/group_vars/all.yml](molecule/default/group_vars/all.yml)
> as an example to create and structure this file.

```shell
./scripts/setup-local-ansible.sh

py-activate

ansible-inventory --graph

ansible-playbook --limit lima-dev-vm playbook-dev-vm.yaml

ansible-playbook --limit lima-dev-vm playbook-dev-vm-home.yaml
```

## Overview

This repository defines reproducible workstation setup through modular Ansible
playbooks and roles, tested locally via Molecule and continuously in GitHub
Actions.

**Ansible Playbooks**

- `playbook-dev-vm.yaml`: performs system‑level setup (requires sudo).
- `playbook-dev-vm-home.yaml`: applies per‑user configuration (non‑sudo).

**Top‑level files**

- `requirements.yml`: Ansible Galaxy role and collection dependencies.
- `requirements.txt`: pinned Python package dependencies for venv and CI.
- `Makefile`: main entry point for linting, testing, and dependency updates.
- `scripts/`: helper scripts, including `setup-local-ansible.sh` to bootstrap
  a virtual environment.

**Roles**

- `roles/phdz_sys_linux_baseline`: base package and service setup.
- `roles/phdz_sys_nix`: installs/configures Nix daemon.
- `roles/phdz_sys_dev_user`: creates the dev user and sudo privileges.
- `roles/phdz_ssh_keys` / `roles/phdz_gpg_keys`: manage SSH and GPG keys.
- `roles/phdz_homeshick`: clones dotfile repositories (“castles”).
- `roles/phdz_nix_home_manager`: applies Nix Home‑Manager configuration.
- `roles/phdz_secure_home`: secures home directory permissions.

**Testing and CI**

- `molecule/`: Molecule scenario definitions for verification.
- `.github/workflows/`: GitHub Actions running linting and Molecule tests.

## Development

### Quick Start

This section helps contributors set up a local development and testing
environment.

```shell
./scripts/setup-local-ansible.sh

py-activate

# Run linting and molecule test
make pre-commit
```

Example Molecule commands:

```shell
# Create a test container
molecule create

# Shell into the test container
molecule shell

# Converge only (apply without destroy)
molecule converge

# Run full test cycle (destroys current and new containers)
molecule test

# Verify after converge
molecule verify

# Cleanup instances
molecule destroy
```

### Update Python dependencies

```shell
make update-requirements
```

## Resources

- [LICENSE](LICENSE)
- [Development Conventions](CONVENTIONS.md)
