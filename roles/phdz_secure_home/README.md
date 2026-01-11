# phdz_secure_home

Lock down sensitive directories in a user's home directory by enforcing ownership and permissions.

This role consumes the shared identity variables computed by the `phdz_defaults`
role:

- `phdz_defaults_user` (default: `null` -> derived)
- `phdz_defaults_group` (default: `null` -> derived)
- `phdz_defaults_home` (default: `null` -> derived)

## Variables

- `phdz_secure_home_allow_missing` (default: `true`): If `true`, missing directories are skipped. If `false`, missing directories cause a failure.
- `phdz_secure_home_lock_home` (default: `true`): If `true`, enforce ownership and mode on the home directory itself (no recursion).
- `phdz_secure_home_home_mode` (default: `'0700'`): Mode to enforce on the home directory itself when `phdz_secure_home_lock_home: true`.
- `phdz_secure_home_dirs_default` (default: `['.ssh', '.gnupg', '.password-store']`): Default secured directories (relative to `phdz_defaults_home`).
- `phdz_secure_home_dirs_extra` (default: `[]`): Additional directories to secure.
- `phdz_secure_home_dirs` (default: `phdz_secure_home_dirs_default + phdz_secure_home_dirs_extra`): Final list of directories.

## Behavior

### Home directory (optional, non-recursive)

When `phdz_secure_home_lock_home: true`, the role enforces ownership and mode on
the home directory itself (no recursion) using `phdz_secure_home_home_mode`.

### Secured directories

For each directory in `phdz_secure_home_dirs`:

- The target path is stat'd with `follow: false`.
- If the target is missing:
  - skipped when `phdz_secure_home_allow_missing: true`
  - failed when `phdz_secure_home_allow_missing: false`
- If the target is a symlink, it is skipped (symlinked directories are not traversed).
- If the target exists but is not a directory, the role fails.
- Permissions enforced:
  - the directory itself: `0700`
  - all directories underneath: `0700`
  - all regular files underneath: `0600`
- Special files (devices, sockets, fifos, symlinks) are ignored because the role only acts on regular files and directories.

## Warnings / caveats

### Symlinked home directories

The role stats the home directory with `follow: false`. If the home directory
path is a symlink, the role skips securing the home directory itself (to avoid
accidentally chmod/chown'ing an unexpected target). The secured subdirectories
are still evaluated relative to the resolved home path.

If your environment intentionally uses symlinked home directories, consider
setting `phdz_defaults_home` explicitly to the real (non-symlink) path.

### `0700` on the home directory may not fit all environments

Enforcing `0700` (or any restrictive mode) on the home directory can break valid
setups where other users or services need to traverse/read parts of a user's
home directory (shared systems, some enterprise/NFS home policies, certain
backup/management agents).

If you encounter issues:
- set `phdz_secure_home_lock_home: false` to disable home-directory enforcement, or
- set `phdz_secure_home_home_mode` to a less restrictive mode appropriate for your environment (e.g. `'0750'`).

## Privilege escalation (`become`)

This role does not set `become`. Run it as the intended user (typical) or with
`become` if you need to fix ownership/modes that the user cannot change.
