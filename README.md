# ansible-playbooks-pedrohdz

Quick setup:

```bash
python3.9 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install ansible ansible-lint molecule[docker] yamllint
ansible-galaxy install -r requirements.yaml
```

Running:

```bash
ansible-playbook playbook.yaml --ask-become-pass
```

Testing and development:

```bash
molecule create
molecule converge
molecule list
molecule login
molecule destroy
```

Complete end to end testing:

```bash
molecule test
```

## Other helpful commands

```bash
ansible-galaxy install -r requirements.yaml --force --force-with-deps
```
