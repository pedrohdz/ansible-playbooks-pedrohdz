# ansible-playbooks-pedrohdz


## Installation

First you need to manually [install MacPorts][INSTALL_MACPORTS] and make sure
the your PATH starts with `/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin`.

Then:

```bash
./scripts/setup-local-ansible.sh
source .venv/bin/activate
```

To run the playbook:

```bash
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
molecule create
molecule converge
molecule list
molecule login
molecule destroy
```

Complete end-to-end testing:

```bash
molecule test
```

Using [Vagrant][VAGRANT] with [VirtualBox][VIRTUAlBOX], the default, can result
in at least 50% faster testing times over [Docker][DOCKER].  If you would like
to run with *Docker* either way:

```bash
molecule create --scenario-name docker
molecule converge --scenario-name docker
molecule test --scenario-name docker
molecule destroy --scenario-name docker
```

[VAGRANT]: https://www.vagrantup.com/
[VIRTUAlBOX]: https://www.virtualbox.org/
[DOCKER]: https://www.docker.com/

Running [github/super-linter](https://github.com/github/super-linter) locally
to help debug GitHub Action issues:

```bash
docker pull github/super-linter:slim-latest
docker run -e RUN_LOCAL=true -v $PWD:/tmp/lint github/super-linter:slim-latest
```

More information can be found at:

- [Run Super-Linter locally to test your branch of code](https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md)


## Other helpful commands

```bash
ansible-galaxy install -r requirements.yaml --force --force-with-deps
```


[INSTALL_MACPORTS]: https://www.macports.org/install.php
