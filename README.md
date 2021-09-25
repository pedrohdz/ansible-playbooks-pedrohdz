# ansible-playbooks-pedrohdz


## Installation

First you need to manually [install MacPorts][INSTALL_MACPORTS] and make sure
the your PATH starts with `/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin`.

Then:

```bash
python3.9 -m venv .venv
source .venv/bin/activate
pip install --upgrade --upgrade-strategy eager wheel pip
pip install ansible ansible-lint 'molecule[docker,lint]' molecule-vagrant python-vagrant
ansible-galaxy install -r requirements.yaml

# Actually install the infrascructure tools on your workstation.  Enter your
# `sudo` password at the prompt.
ansible-playbook playbook.yaml --ask-become-pass
```

Update your `~/.profile` with:

```sh
export PATH="/opt/devenv/bin:/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin:$PATH"
export MANPATH="/opt/local/share/man:$MANPATH"
```

In your `~/.bashrc`, add the following to get the Bash completions:

```bash
source /opt/devenv/etc/bash_completion.d/*.sh
source /opt/local/etc/bash_completion.d/*
```


## Testing and development

```bash
pip install ansible ansible-lint molecule[docker] yamllint

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

Running [github/super-linter](https://github.com/github/super-linter) locally
to help debug GitHub Action issues:

```bash
docker run -e RUN_LOCAL=true -v $PWD:/tmp/lint github/super-linter
```

More information can be found at:

- [Run Super-Linter locally to test your branch of code](https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md)


## Other helpful commands

```bash
ansible-galaxy install -r requirements.yaml --force --force-with-deps
```


[INSTALL_MACPORTS]: https://www.macports.org/install.php
