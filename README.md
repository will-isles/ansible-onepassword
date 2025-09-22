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
- `playbooks/setup.yml` – umbrella playbook that imports the individual setup
  plays.
- `playbooks/setup_onepassword.yml` – installs the `onepassword` role.
- `playbooks/setup_git.yml` – configures the SSH agent and clones GitHub
  projects.
- `roles/onepassword/` – installs the repository and layers packages via
  `community.general.rpm_ostree_pkg`.
- `roles/onepassword_ssh_agent/` – configures dotfiles for the 1Password SSH
  agent on Linux when enabled.
- `roles/github_projects/` – clones configurable GitHub repositories into a
  configurable directory under the calling user.

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
- `onepassword_ssh_agent_enabled` – `false` (default). Set to `true` to configure
  the 1Password SSH agent environment on Linux.
- `onepassword_ssh_agent_manage_env` – `true` (default). Writes
  `~/.config/environment.d/1password-ssh-agent.conf` with `SSH_AUTH_SOCK`.
- `onepassword_ssh_agent_manage_ssh_config` – `true` (default). Adds an
  `IdentityAgent` block for each pattern in `onepassword_ssh_agent_ssh_hosts`
  (default `['*']`).
- `onepassword_ssh_agent_create_symlink` – `false` (default). Set to `true` to
  link `~/.ssh/agent.sock` to the 1Password socket for legacy tooling.
- `git_projects_clone_root` – `~/Projects-testing` (default). Base directory
  where repositories are cloned.
- `git_projects_repositories` – default list includes the
  `will-isles/ansible-onepassword` and `will-isles/ansible-linux` repositories.
  Override with a list of dictionaries containing `repo` URLs and optional
  `name`/`dest` keys to manage additional projects.
- `git_projects_git_user_name` / `git_projects_git_user_email` – set these when
  you want the role to initialize your global Git identity. They default to
  `null` so existing Git configurations are left untouched.

Usage
-----

Run against localhost and supply sudo credentials when prompted:

```sh
ansible-playbook playbooks/setup.yml --ask-become-pass
```

You can target only part of the workflow with
`playbooks/setup_onepassword.yml` or `playbooks/setup_git.yml` as needed.

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

1Password SSH Agent
-------------------

Set `onepassword_ssh_agent_enabled: true` to have the playbook configure your
shell and OpenSSH for the 1Password SSH agent. When enabled, the
`onepassword_ssh_agent` role:

- populates `~/.config/environment.d/1password-ssh-agent.conf` with
  `SSH_AUTH_SOCK={{ onepassword_ssh_agent_socket }}` so new sessions know where
  to reach the agent;
- adds an `IdentityAgent` stanza for every entry in
  `onepassword_ssh_agent_ssh_hosts` (default `['*']`) to `~/.ssh/config`; and
- optionally symlinks `~/.ssh/agent.sock` to the 1Password socket when
  `onepassword_ssh_agent_create_symlink` is set to `true`.

After the dotfiles are in place:

1. **Create or import an SSH key.** Open 1Password, choose **New Item → SSH
   Key**, then either generate an Ed25519/RSA key or paste an existing private
   key. Save the item and copy the public key into whichever Git hosting
   service or server account needs it.
2. **Turn on the agent in the desktop app.** Select your account avatar →
   **Settings → Developer → Set Up SSH Agent** and follow the prompts. Leave
   "Display key names" enabled if you want prompts to show which key is being
   requested. Under **Settings → General** enable **Keep 1Password in the
   system tray** and **Start at login** so the agent remains running in the
   background.
3. **Authorize client requests.** The first time each terminal, IDE, or other
   SSH client uses a stored key, 1Password prompts you to approve it. Adjust the
   approval frequency under **Settings → Developer → SSH Agent** to fit your
   workflow.

Advanced users can further tune which vaults or keys the agent offers by
creating `~/.config/1Password/ssh/agent.toml` with the desired configuration.
The agent is only available when 1Password is installed from a traditional
package (not Flatpak or Snap) and when the desktop app stays running/unlocked.
