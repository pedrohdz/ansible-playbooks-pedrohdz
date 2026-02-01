# CONVENTIONS.md

This repository contains Ansible playbooks/roles plus CI and Molecule tests.
These conventions exist to keep changes consistent, idempotent, and compatible
with the repo’s linters and GitHub Actions.

## General principles
- Prefer small, reviewable diffs over large refactors.
- Keep changes consistent with existing patterns in the repo.
- Changes should be idempotent (safe to run repeatedly).

## Files, paths, and naming
- Prefer `.yaml` (this repo primarily uses `.yaml`).

## Naming: public vs private
### Public (stable) names
- All public variables, facts, roles, and similar identifiers should be
  prefixed with `phdz_`.
  - Examples:
    - `phdz_homeshick_repo_url`
    - `phdz_homeshick_castles`

### Private (internal) names
- Variables and facts intended to be internal/private should be prefixed with
  `_phdz_`.
  - Use this for intermediate values, derived values, loop helpers, etc.
  - Examples:
    - `_phdz_homeshick_target_dir`
    - `_phdz_effective_repo_dir`

## Task naming
- Task names should be descriptive and action-oriented.
- Do not prefix normal task names with `role_name |`.
  - Good: `Ensure homeshick is cloned`
  - Avoid: `phdz_homeshick | Ensure homeshick is cloned`

## Notify / handler conventions (use `listen`)
### Notification event names
- Notification “event” names (what tasks `notify:`) must be prefixed with
  `role_name | event`.
  - Example notify string: `phdz_homeshick | on-clone-updated`

### Handler task names
- Handler task names should follow the normal task naming convention:
  - descriptive, action-oriented
  - no `role_name |` prefix in the handler task’s `name:`

### Use `listen` to connect them
- Handlers should use `listen:` to bind one or more handler tasks to a single
  notification event name. This lets:
  - tasks `notify:` a stable, role-prefixed event name (avoids collisions)
  - handler tasks keep clean, descriptive names

## Tags
- Use tags to enable safe, coarse-grained partial runs; avoid tagging every task.
- Prefer tagging at the play/block/role include level (not individual tasks).
- Tags are a selection mechanism, not dependencies; tagged runs should be as
  self-contained as practical.

### Tag naming
- Use short, stable, lowercase tags.
- Prefer domain and scope tags:
  - Domain: `packages`, `pyvenv_apps`, `homeshick`
  - Scope: `baseline`, `workstation`, `home`
  - OS (when useful): `debian`, `ubuntu`, `darwin`

### Dangerous / opt-in work
- For destructive or risky actions, require explicit opt-in:
  - `tags: [never, cleanup]` (or similar)

### Where to apply tags (recommended)
- Playbooks: tag the top-level role entries and OS-specific blocks.
- Roles: only add tags inside roles if running the role standalone benefits.

## Put calculations in `vars:` blocks
- Prefer putting “calculation” / derived values into a `vars:` section on the
  task (or block) and reference them in module arguments.
- This improves readability and reduces repeated Jinja expressions.

Example pattern:

```yaml
- name: Ensure homeshick castles are cloned
  ansible.builtin.git:
    repo: '{{ item }}'
    dest: '{{ phdz_homeshick_repo_dir }}/{{ _phdz_target_dir }}'
    update: false
  loop: '{{ phdz_homeshick_castles }}'
  when: phdz_homeshick_castles | length > 0
  notify: phdz_homeshick | on-clone-updated
  vars:
    _phdz_target_dir: >-
      {{ (item | regex_replace('.*/', '')) | regex_replace('\.git$', '') }}
```

## Ansible task/role style
- Always set a meaningful `name:` for each task and handler.
- Prefer Ansible modules over `shell`/`command`.
- If `command`/`shell` is necessary:
  - Be explicit why.
  - Ensure idempotency using `creates`, `removes`, or `changed_when`/`failed_when`.
- Use `become: false` for user-scoped configuration unless root is required.
- Use `register:` only when the result is used (or is needed for notify/debug).
- Keep roles structured conventionally:
  - `defaults/` for user-overridable settings
  - `vars/` for internal constants
  - `tasks/` for logic
  - `handlers/` for notified actions

## Git usage in Ansible
- When cloning repositories:
  - Be explicit about `repo`, `dest`, and `version` (tag/branch).
  - Prefer predictable behavior over implicit updates.
  - If you set `update: false`, document why (e.g., to avoid unexpected changes).

## YAML formatting and linting
- Follow repo lint configs:
  - `.ansible-lint`
  - `.yamllint`
- Don’t “format fight” the linters—adjust code to pass.

## Line length and wrapping (79 chars when reasonable)

Keep YAML lines to ~79 characters when practical. Wrap long expressions for
readability and cleaner diffs.

### Wrapping `when:` conditions

Prefer list-form `when:` for multiple conditions. A `when:` list is an implicit
logical **AND**: all items must be true.

- Use **list-form** for long **AND** chains (one condition per line).
- Put **OR** logic inside a *single* condition (since list items do not OR
  together).
- For long boolean expressions, use a folded scalar (`>-`) and wrap so
  continuation lines begin with the boolean operator (`and` / `or`).

Examples:

```yaml
# Long AND chain: list-form `when:`
when:
  - phdz_feature_enabled | bool
  - ansible_os_family == 'Debian'
  - phdz_mode == 'workstation'
  - phdz_packages | length > 0
```

```yaml
# Long OR condition: keep ORs within a single item and wrap with `>-`
when:
  - ansible_os_family == 'Debian'
  - >-
    (phdz_install_method == 'apt')
    or (phdz_install_method == 'backports')
    or (phdz_install_method == 'source')
```

```yaml
# Mixed grouping: use a single wrapped expression when you need parentheses
when: >-
  ((phdz_mode == 'workstation') and (ansible_os_family == 'Debian'))
  or ((phdz_mode == 'home') and (ansible_os_family == 'Darwin'))
```

## YAML quoting (single-quote default)

Prefer **single quotes** for YAML scalars whenever possible. This keeps YAML
strings consistent and avoids accidental escape-sequence behavior.

Use **double quotes** only when needed (e.g., when you want YAML escape
sequences like `\n`, `\t`, or `\uXXXX`, or when avoiding awkward quoting would
harm readability).

### Nesting quotes
When you need quotes *inside* a string, prefer:
- **outer single quotes**
- **inner double quotes**

Examples:

```yaml
# Jinja expressions: single-quote the whole scalar
dest: '{{ phdz_homeshick_repo_dir }}/{{ _phdz_target_dir }}'

# Regex strings: single quotes, escape backslashes only as needed for the regex
_phdz_target_dir: >-
  {{ (item | regex_replace('.*/', '')) | regex_replace('\.git$', '') }}

# Shell/command snippets: outer single quotes, inner double quotes
ansible.builtin.command:
  cmd: 'printf "%s\n" "{{ item }}"'
```

## Local development workflow
Use the Makefile targets as the canonical interface:
- `make pre-commit` (runs `super-linter` + `molecule-test`)
- `make molecule-test`, `make molecule-converge`
  - `MOLECULE_SCENARIO=default make molecule-test`
- `make super-linter`
- `make update-requirements`
- `make clean`

## CI expectations
GitHub Actions runs:
- Super-Linter
- Molecule tests on Ubuntu
- macOS integration (MacPorts) after lint + molecule succeed

Keep CI green:
- Avoid OS-specific assumptions unless guarded by `when:` checks.
- Condition platform behavior on facts like `ansible_os_family` /
  `ansible_distribution`.

## Documentation expectations
- If you add/change public variables:
  - Put defaults in the appropriate `defaults/main.yaml`.
  - Document them (role README and/or repo docs).
- If you change a workflow/command, keep `README.md` accurate.

## Defaults location and usage

- All shared or baseline defaults belong in `roles/phdz_defaults/`.
- Other roles should reference these values instead of redefining them.
- When a role needs its own derived or adjusted default
  (for example, `phdz_nix_home_manager_home_dir`),
  define it as a local copy of the appropriate `phdz_defaults_*` variable.
- Document any intentional deviations, and keep naming consistent
  (`_phdz_` for internal derived values, `phdz_` for public ones).
