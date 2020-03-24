#!make
include .env
export $(shell sed 's/=.*//' .env)
export ANSIBLE_CONFIG=./ansible.cfg

# If the first argument is "run"...
ifeq (tower-cli,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

.PHONY: playbook build ping test init restore list-backups attach destroy install-roles list-roles tower-cli

default:
	@./run.sh

tower-cli: build
	@docker run \
		--rm \
		-it \
		-e ANSIBLE_CONFIG=/ansible/ansible.cfg \
		--env-file .env \
		-v `pwd`:/ansible \
		-v $(ANSIBLE_SSH_PRIVATE_KEY_FILE):/root/.ssh/ansible_ssh_private_key:ro \
		conatel_digital_hub/awx_vpn \
		tower-cli $(RUN_ARGS)

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
	@docker build -t conatel_digital_hub/awx_vpn \
	--build-arg TOWER_VERIFY_SSL=$(TOWER_VERIFY_SSL) \
	--build-arg TOWER_USERNAME=$(TOWER_USERNAME) \
	--build-arg TOWER_PASSWORD=$(TOWER_PASSWORD) \
	--build-arg TOWER_HOST=$(TOWER_HOST) . > /dev/null

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