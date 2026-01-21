# ansible-playbooks-pedrohdz

```shell
ansible-playbook playbook-home.yaml


```

## phdz_ssh_keys

Manage SSH `authorized_keys` and `known_hosts` for the user running the play.

This role is user-scoped. It creates `~/.ssh` if needed and manages entries when
the corresponding input lists are non-empty.

This role depends on `phdz_defaults` to resolve the user home directory via
`phdz_defaults_home`.

### Variables

#### `phdz_ssh_keys_authorized_keys` (default: `[]`)

List of authorized key entries to manage.

Example:

```yaml
phdz_ssh_keys_authorized_keys:
  - key: 'ssh-ed25519 AAAAC3... user@example.invalid'
    state: present
    comment: 'laptop'
```

#### `phdz_ssh_keys_known_hosts` (default: `[]`)

List of known_hosts entries to manage.

Optional field:
- `description`: used only for Ansible loop labeling / output readability

Example:

```yaml
phdz_ssh_keys_known_hosts:
  - name: github.com
    description: github.com (ssh-ed25519)
    key: >-
      github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFakeFakeFakeFakeFakeFakeFakeFakeFakeFakeFakeFakeFake
    state: present
```

#### `phdz_ssh_keys_hash_known_hosts` (default: `false`)

If true, set `hash_host: true` when writing entries with
`ansible.builtin.known_hosts`.

### Permissions

This role focuses on ensuring the required files/directories exist and that
entries are managed idempotently. If you want centralized enforcement of
permissions, pair it with the `phdz_secure_home` role.
