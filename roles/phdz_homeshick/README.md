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
- phdz_homeshick_ssh_socket_key: token used to distinguish ControlMaster sockets in phdz_homeshick_ssh_opts (default '%r@%h:%p'); the castles task overrides this per item with the URL's owner/namespace so different Git accounts on the same host never share a multiplexed socket
- phdz_homeshick_castle_ssh_opts: mapping of owner/namespace -> extra ssh_opts (e.g. `-o IdentityFile=...`) appended when cloning a castle, used to pick the correct account identity for a castle's initial clone (empty by default; populate via host_vars or a private vars file)

Dependencies
- None

Example Playbook
- hosts: all
  roles:
    - phdz_homeshick

License
MIT
