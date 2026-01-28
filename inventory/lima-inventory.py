#!/usr/bin/env python3
"""
Dynamic Ansible inventory for Lima VMs.

Produces inventory JSON by parsing `limactl list --format=yaml`.
If `limactl` is unavailable or no VMs are running, it exits
successfully, writes a brief notice to stderr, and returns {}.
"""

import argparse
import json
import subprocess
import sys
import shutil
import yaml


def get_lima_instances():
    """Return list of parsed YAML documents from `limactl list --format=yaml`."""
    if not shutil.which("limactl"):
        sys.stderr.write("lima-inventory: 'limactl' not found; returning empty inventory\n")
        return []

    try:
        proc = subprocess.run(
            ["limactl", "list", "--format=yaml"],
            check=True,
            text=True,
            capture_output=True,
        )
    except subprocess.CalledProcessError as exc:
        sys.stderr.write(f"lima-inventory: failed to run limactl ({exc}); returning empty inventory\n")
        return []

    try:
        docs = list(yaml.safe_load_all(proc.stdout))
    except yaml.YAMLError as exc:
        sys.stderr.write(f"lima-inventory: YAML parse error ({exc}); returning empty inventory\n")
        return []

    return docs


def build_inventory(docs):
    """Convert parsed YAML documents to an Ansible inventory dictionary."""
    hosts = []
    hostvars = {}

    for doc in docs:
        inst = doc.get("instance", {})
        if inst.get("status") != "Running":
            continue

        hostname = inst.get("hostname")
        ssh_conf = inst.get("sshConfigFile")
        if not hostname or not ssh_conf:
            continue

        hosts.append(hostname)
        hostvars[hostname] = {
            "ansible_connection": "ssh",
            "ansible_ssh_common_args": f"-F {ssh_conf} -o ControlMaster=no",
        }

    if not hosts:
        return {}

    return {
        "all": {"children": ["lima_vm"]},
        "lima_vm": {"hosts": hosts, "children": []},
        "_meta": {"hostvars": hostvars},
    }


def main():
    parser = argparse.ArgumentParser(description="Lima dynamic inventory for Ansible")
    parser.add_argument("--list", action="store_true", help="List all hosts")
    parser.add_argument("--host", help="Host-specific variable query (unused)")
    args = parser.parse_args()

    docs = get_lima_instances()
    inventory = build_inventory(docs)

    if not inventory:
        # Empty inventory scenario
        sys.stderr.write("lima-inventory: returning empty inventory\n")
        json.dump({}, sys.stdout)
        sys.exit(0)

    if args.host:
        json.dump({}, sys.stdout)
    else:
        json.dump(inventory, sys.stdout, indent=2)

    sys.exit(0)


if __name__ == "__main__":
    main()
