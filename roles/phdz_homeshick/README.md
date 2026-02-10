Role Name: phdz_homeshick

This role will install the homeshick repository into the current user's home directory.
This is the initial skeleton created with ansible-galaxy init to begin development.

Requirements
- Git available on the target

Role Variables
- phdz_homeshick_repo_url: URL to the homeshick repository
- phdz_homeshick_version: tag/branch to checkout for homeshick (default v2.0.1)
- phdz_homeshick_repo_dir: base directory where homeshick and castles are cloned
- phdz_homeshick_castles: list of git URIs for castles to clone into phdz_homeshick_repo_dir

Dependencies
- None

Example Playbook
- hosts: all
  roles:
    - phdz_homeshick

License
MIT
