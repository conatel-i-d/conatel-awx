#!make
include .env
export $(shell sed 's/=.*//' .env)
export ANSIBLE_CONFIG=./ansible.cfg

.PHONY: playbook build ping test init restore list-backups attach destroy install-roles list-roles

default:
	@./run.sh

install-roles:
	@rm -Rf roles \
	&& ansible-galaxy install -r requirements.yml -p roles --force

list-roles:
	@ansible-galaxy list

destroy:
	@make playbook file=destroy.yml

init:
	@make playbook file=init.yml

restore:
	@make playbook file=restore.yml

list-backups:
	@make playbook file=list-backups.yml

backup:
	@make playbook file=backup.yml

up:
	@make playbook file=up.yml

ping:
	@make playbook file=ping.yml

build:
	@docker build -t conatel_digital_hub/awx_vpn . > /dev/null

attach: build
	@docker run \
		--rm \
		-it \
		-e ANSIBLE_CONFIG=/ansible/ansible.cfg \
		--env-file .env \
		-v `pwd`:/ansible \
		-v $(ANSIBLE_SSH_PRIVATE_KEY_FILE):/root/.ssh/ansible_ssh_private_key:ro \
		conatel_digital_hub/awx_vpn \
		bash

playbook: build
	@docker run \
		--rm \
		-it \
		-e ANSIBLE_CONFIG=/ansible/ansible.cfg \
		--env-file .env \
		-v `pwd`:/ansible \
		-v $(ANSIBLE_SSH_PRIVATE_KEY_FILE):/root/.ssh/ansible_ssh_private_key \
		conatel_digital_hub/awx_vpn \
		ansible-playbook $(file)