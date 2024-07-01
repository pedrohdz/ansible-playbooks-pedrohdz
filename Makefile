BUILD_RAND_NAME ?= $(shell tr -dc a-z0-9 </dev/urandom | head -c 13)

DEFAULT_BRANCH      ?= master
MOLECULE_SCENARIO   ?= docker
SUPER_LINTER_IMAGE  ?=ghcr.io/super-linter/super-linter:v6

simple_molecule_targets := \
	molecule-converge \
	molecule-test

all_phony_targets := \
	$(simple_molecule_targets) \
	clean \
	molecule-destroy \
	pre-commit \
	super-linter \
	update-requirements

.PHONY: $(all_phony_targets)


#------------------------------------------------------------------------------
# Targets
#------------------------------------------------------------------------------
all: pre-commit

pre-commit: super-linter molecule-test

$(simple_molecule_targets):
	@echo MOLECULE_SCENARIO='$(MOLECULE_SCENARIO)'
	bash -c 'set -e; \
		source .venv/bin/activate; \
		molecule $(@:molecule-%=%) --scenario-name $(MOLECULE_SCENARIO)'

molecule-destroy:
	@echo MOLECULE_SCENARIO='$(MOLECULE_SCENARIO)'
	bash -c 'set -e; \
		source .venv/bin/activate || exit 0 \
		molecule destroy --scenario-name $(MOLECULE_SCENARIO)'

# TODO - Turn Checkov back on.
super-linter:
	docker image pull --platform linux/amd64 $(SUPER_LINTER_IMAGE)
	docker run \
		--tty --rm \
		--env DEFAULT_BRANCH=$(DEFAULT_BRANCH) \
		--env IGNORE_GITIGNORED_FILES=true \
		--env RUN_LOCAL=true \
		--env SHELL=/bin/bash \
		--env VALIDATE_CHECKOV=false \
		--env VALIDATE_SHELL_SHFMT=false \
		--name ansible-playbooks-avinode-super-linter-$(BUILD_RAND_NAME) \
		--platform linux/amd64 \
		--volume $$PWD:/tmp/lint \
		$(SUPER_LINTER_IMAGE)

clean:
	rm -Rf .venv/ .ansible/

update-requirements: | clean _update-requirements clean

_update-requirements:
	/opt/local/bin/python3 -m venv .venv
	.venv/bin/pip install --upgrade --upgrade-strategy eager wheel setuptools pip
	.venv/bin/pip install \
			ansible \
			ansible-lint \
			certifi \
			molecule \
			'molecule-plugins[docker,vagrant]' \
			python-vagrant
	.venv/bin/pip freeze > requirements.txt

help:
	$(info $(HELP))


#------------------------------------------------------------------------------
# Other
#------------------------------------------------------------------------------
define HELP
Please call with one of the following targets:

  $(sort $(all_phony_targets))

endef
