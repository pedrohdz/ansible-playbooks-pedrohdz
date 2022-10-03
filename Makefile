BUILD_RAND_NAME ?= $(shell tr -dc a-z0-9 </dev/urandom | head -c 13)

MOLECULE_SCENARIO := docker

simple_molecule_targets := \
	molecule-converge \
	molecule-test

all_phony_targets := \
	$(simple_molecule_targets) \
	pre-commit \
	super-linter

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

super-linter:
	# TODO - Turn `GITHUB_ACTIONS` back on once it is working again.
	docker run \
			--rm \
			--env RUN_LOCAL=true \
			--env PYTHONPATH=/tmp/lint/.venv/lib/python3.8/site-packages \
			--env VALIDATE_GITHUB_ACTIONS=false \
			--volume $$PWD:/tmp/lint \
			--name ansible-playbooks-avinode-super-linter-$(BUILD_RAND_NAME) \
			github/super-linter

help:
	$(info $(HELP))


#------------------------------------------------------------------------------
# Other
#------------------------------------------------------------------------------
define HELP
Please call with one of the following targets:

  $(sort $(all_phony_targets))

endef
