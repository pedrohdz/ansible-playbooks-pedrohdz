#! /bin/bash

set -o errexit
set -o pipefail
set -o nounset

INSTALL_DIR=${GITHUB_WORKSPACE:-$PWD}

echo "++ INFO - Setting up the project in: $INSTALL_DIR"
if [ -e "${INSTALL_DIR}/.venv" ]; then
  echo "++ ERROR - Already exists: ${INSTALL_DIR}/.venv"
  exit 1
fi

set -o xtrace

/usr/bin/python3 -m venv "${INSTALL_DIR}/.venv"
# shellcheck disable=SC1091  # File needs to be generated by venv.
source "${GITHUB_WORKSPACE}/.venv/bin/activate"
pip3 install --upgrade --upgrade-strategy eager pip
pip3 install ansible molecule[docker]
ansible --version
molecule --version
ansible-galaxy install -r requirements.yaml
