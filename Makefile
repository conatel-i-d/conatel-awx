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

.PHONY: playbook build ping test init restore list-backups attach destroy install-roles list-roles tower-cli pull

default:
	@./run.sh

pull:
	./scripts/pull.sh

pull-silent:
	@make pull > /dev/null 2>&1

tower-cli: pull-silent
	@docker run \
		--rm \
		-it \
		-e ANSIBLE_CONFIG=/ansible/ansible.cfg \
		--env-file .env \
		-v `pwd`:/ansible \
		-v $(ANSIBLE_SSH_PRIVATE_KEY_FILE):/root/.ssh/ansible_ssh_private_key:ro \
		conateldigitalhub/conatel-awx \
		tower-cli $(RUN_ARGS)

create-roles-folder:
	@mkdir -p roles

install-roles:
	@rm -Rf roles ;\
	make create-roles-folder ;\
	ansible-galaxy install -r requirements.yml -p roles --force

list-roles: create-roles-folder
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
	docker build -t conateldigitalhub/conatel-awx \
	--build-arg TOWER_VERIFY_SSL=$(TOWER_VERIFY_SSL) \
	--build-arg TOWER_USERNAME=$(TOWER_USERNAME) \
	--build-arg TOWER_PASSWORD=$(TOWER_PASSWORD) \
	--build-arg TOWER_HOST=$(TOWER_HOST) .

attach: pull-silent
	@docker run \
		--rm \
		-it \
		-e ANSIBLE_CONFIG=/ansible/ansible.cfg \
		--env-file .env \
		-v `pwd`:/ansible \
		-v $(ANSIBLE_SSH_PRIVATE_KEY_FILE):/root/.ssh/ansible_ssh_private_key:ro \
		conateldigitalhub/conatel-awx \
		bash

playbook: pull-silent
	@docker run \
		--rm \
		-it \
		-e ANSIBLE_CONFIG=/ansible/ansible.cfg \
		--env-file .env \
		-v `pwd`:/ansible \
		-v $(ANSIBLE_SSH_PRIVATE_KEY_FILE):/root/.ssh/ansible_ssh_private_key \
		conateldigitalhub/conatel-awx \
		ansible-playbook $(file)