#! /bin/bash

set -o errexit
set -o pipefail
set -o nounset

#------------------------------------------------------------------------------
# Configure & sanity check
#------------------------------------------------------------------------------
PYTHON=/usr/bin/python3
PROJECT_DIR="$(builtin cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"
INSTALL_DIR=${GITHUB_WORKSPACE:-$PROJECT_DIR}
echo "++ INFO - Setting up the project in: $INSTALL_DIR"
if [ -e "${INSTALL_DIR}/.venv" ]; then
  echo "++ ERROR - Already exists: ${INSTALL_DIR}/.venv"
  exit 1
fi

set -o xtrace


#------------------------------------------------------------------------------
# Setup Python venv
#------------------------------------------------------------------------------
"$PYTHON" -m venv "${INSTALL_DIR}/.venv"

set +o xtrace
# shellcheck disable=SC1091  # File needs to be generated by venv.
source "${INSTALL_DIR}/.venv/bin/activate"
set -o xtrace

pip3 install --upgrade --upgrade-strategy eager pip setuptools wheel
pip3 install ansible ansible-lint 'molecule[docker,lint]'

which vagrant > /dev/null \
    && pip3 install molecule-vagrant python-vagrant


#------------------------------------------------------------------------------
# Record versions
#------------------------------------------------------------------------------
which "$PYTHON"
"$PYTHON" --version

which ansible ansible-lint molecule yamllint ansible-galaxy
ansible --version
ansible-lint --version
molecule --version
yamllint --version
pip3 freeze


#------------------------------------------------------------------------------
# Ansible setup
#------------------------------------------------------------------------------
ansible-galaxy install -r requirements.yml