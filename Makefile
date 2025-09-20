.PHONY: run check syntax lint

run:
	ansible-playbook playbooks/setup.yml --ask-become-pass

check:
	ansible-playbook playbooks/setup.yml --check --diff

syntax:
	ansible-playbook playbooks/setup.yml --syntax-check

lint:
	pipx run ansible-lint
