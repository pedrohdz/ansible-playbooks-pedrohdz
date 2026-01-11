# phdz_gpg_keys

Imports embedded ASCII-armored **public** GPG keys into the user keyring and
(optionally) sets those keys to **ultimate** trust via GPG ownertrust.

## Requirements

- `gpg` available on the target host (Debian/Ubuntu package: `gnupg`).
- Role depends on `phdz_defaults` for `phdz_defaults_home`.

## Role variables

### `phdz_gpg_keys_public` (default: `[]`)
List of embedded ASCII-armored public keys to import.

Example:

```yaml
phdz_gpg_keys_public:
  - |
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    ...
    -----END PGP PUBLIC KEY BLOCK-----
```

### `phdz_gpg_keys_homedir` (default: `{{ phdz_defaults_home }}/.gnupg`)
GnuPG home directory to use for all operations.

### `phdz_gpg_keys_ultimate_trust` (default: `false`)
If `true`, the role sets ownertrust to **ultimate** (`6`) for the fingerprints
derived from `phdz_gpg_keys_public`.

## Notes

- This role imports public keys only; it does not manage secret keys.
- Setting ownertrust modifies the keyring trustdb (`trustdb.gpg`).
