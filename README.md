1Password Installer (rpm-ostree)
================================

This repository packages a minimal Ansible playbook that layers the official
1Password RPM (and optionally the CLI) onto a Fedora Atomic host via
`rpm-ostree`. Everything runs against `localhost`; the role escalates with
`become` only for the repository and package tasks.

Project Layout
--------------

- `ansible.cfg` – points Ansible at the local inventory and role path.
- `inventories/local/hosts.ini` – defines the `local` host (localhost
  connection).
- `inventories/local/group_vars/all.yml` – central place to set the
  `onepassword_*` variables.
- `playbooks/setup.yml` – entry play that includes the `onepassword` role.
- `roles/onepassword/` – installs the repository and layers packages via
  `community.general.rpm_ostree_pkg`.

Requirements
------------

- Homebrew on your Fedora Atomic host. On a fresh system run:

  ```sh
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ```

  The profile line persists `brew` in future shells; adjust the file name for
  your preferred shell.
- Ansible 9+ installed via Homebrew:

  ```sh
  brew install ansible
  ```

- The `community.general` collection (install with
  `ansible-galaxy collection install -r collections/requirements.yml`).
- A Fedora Atomic (rpm-ostree based) system where you can escalate with sudo.

Configuration
-------------

Override the defaults in `inventories/local/group_vars/all.yml` or with `-e`:

- `onepassword_channel` – `stable` (default) or `beta`.
- `onepassword_install_cli` – `false` (default) or `true` to add `1password-cli`.

Usage
-----

Run against localhost and supply sudo credentials when prompted:

```sh
ansible-playbook playbooks/setup.yml --ask-become-pass
```

You can limit to check mode first:

```sh
ansible-playbook playbooks/setup.yml --check --diff
```

Make Targets
------------

The Makefile mirrors the common Ansible invocations:

- `make run` – apply the play.
- `make check` – run playbook in check mode with diff.

Validation
----------

After a successful run, reboot the host (or `systemctl reboot`) so the new
rpm-ostree deployment becomes active. Subsequent runs should result in zero
changes unless you flip `onepassword_install_cli` or switch channels.
