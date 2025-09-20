# Repository Guidelines

## Scope
- Focus exclusively on installing 1Password on Fedora Atomic hosts.
- Keep automation user-scoped by default; escalate only where package
  management requires it.

## Layout
- `playbooks/setup.yml` installs the single `onepassword` role.
- `roles/onepassword/` follows the standard Ansible role tree (only
  `defaults/` and `tasks/` today).
- Inventory lives in `inventories/local/`; set overrides in
  `group_vars/all.yml`.

## Commands
- `make run` → `ansible-playbook playbooks/setup.yml`.
- `make check` → run in check mode with diff.
- `ansible-playbook playbooks/setup.yml --syntax-check` and
  `pipx run ansible-lint` keep changes healthy.

## Variables
- Overridable defaults belong in `defaults/main.yml`.
- Use snake_case variables (e.g. `onepassword_install_cli`).

## Testing
- Run `make check` before `make run`.
- Expect zero changes on a second `make run` unless channel/CLI settings
  changed.

## Docs & References
- Document any new defaults in `README.md`.
- Upstream references: `/websites/ansible_ansible`,
  `/ansible-collections/community.general`.
