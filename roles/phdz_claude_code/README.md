# phdz_claude_code

Installs the [Claude Code](https://code.claude.com/docs/) CLI for the current
user via Anthropic's upstream native installer
(`https://claude.ai/install.sh`). The installer places a self-contained
binary under the user's home directory (`~/.local/bin/claude`) — no `sudo`
or Node.js/npm is required.

## Requirements

- `bash` and outbound internet access on the target.
- Role depends on `phdz_defaults` for `phdz_defaults_home`.
- Should be run with `become: false` (user-scoped install).

## Role variables

### `phdz_claude_code_installer_url`
URL to the upstream native installer script
(default: `https://claude.ai/install.sh`).

### `phdz_claude_code_version`
Release channel (`stable` or `latest`) or a specific version number
(e.g. `2.1.89`) passed through to the installer (default: `stable`).

### `phdz_claude_code_home_dir`
Home directory the CLI is installed into
(default: `{{ phdz_defaults_home }}`).

### `phdz_claude_code_bin_path`
Path to the installed `claude` binary, also used as the idempotency check
(default: `{{ phdz_claude_code_home_dir }}/.local/bin/claude`).

## Notes

- The installer is downloaded fresh each run only when
  `phdz_claude_code_bin_path` does not yet exist; re-runs are a no-op.
- Native installations auto-update themselves in the background; this role
  does not manage upgrades.

## Dependencies

- `phdz_defaults`

## Example playbook

```yaml
- hosts: all
  become: false
  roles:
    - phdz_claude_code
```
