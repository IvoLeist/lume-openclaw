SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ENV_FILE ?= $(ROOT_DIR).env
CMD ?= openclaw status
MODEL ?=
LOCAL_PATH ?=
REMOTE_PATH ?=

.DEFAULT_GOAL := help

SETUP := if [ -f "$(ENV_FILE)" ]; then set -a; . "$(ENV_FILE)"; set +a; fi; cd "$(ROOT_DIR)"

.PHONY: help install-lume vm-install create-openclaw-vm vm-create start-vm vm-start start-vm-with-display vm-ui stop-vm vm-stop restart-vm vm-restart launch-vm-and-gateway vm-launch install-postgres-vm vm-install-postgres openclaw-gateway gateway openclaw-stop gateway-stop openclaw-tui tui openclaw-in-vm run set-default-model model-set peekaboo-status ssh-vm ssh copy-to-vm

help:
	$(SETUP)
	printf '%s\n' \
		'Available targets:' \
		'  make install-lume | vm-install' \
		'  make create-openclaw-vm | vm-create' \
		'  make start-vm | vm-start' \
		'  make start-vm-with-display | vm-ui' \
		'  make stop-vm | vm-stop' \
		'  make restart-vm | vm-restart' \
		'  make launch-vm-and-gateway | vm-launch' \
		'  make install-postgres-vm | vm-install-postgres' \
		'  make openclaw-gateway | gateway' \
		'  make openclaw-stop | gateway-stop' \
		'  make openclaw-tui | tui' \
		'  make openclaw-in-vm | run CMD="openclaw status"' \
		'  make set-default-model | model-set MODEL="..."' \
		'  make peekaboo-status' \
		'  make ssh-vm | ssh' \
		'  make copy-to-vm LOCAL_PATH=... REMOTE_PATH=...'
	printf '%s\n' \
		'' \
		'Every target loads environment variables from .env before running.' \
		'Place VM_USER and any other shared settings there to avoid exporting them manually.'

print-env:
	$(SETUP); env | sort | grep -E '^(IPSW|VM_USER)'

install-lume vm-install:
	$(SETUP); ./scripts/vm/install-lume.sh

create-openclaw-vm vm-create:
	$(SETUP); ./scripts/vm/create-openclaw-vm.sh

start-vm vm-start:
	$(SETUP); ./scripts/vm/start-vm.sh

start-vm-with-display vm-ui:
	$(SETUP); ./scripts/vm/start-vm-with-display.sh

stop-vm vm-stop:
	$(SETUP); ./scripts/vm/stop-vm.sh

restart-vm vm-restart:
	$(SETUP); ./scripts/vm/stop-vm.sh; ./scripts/vm/start-vm.sh

launch-vm-and-gateway vm-launch:
	$(SETUP); ./scripts/vm/launch-vm-and-gateway.sh

install-postgres-vm vm-install-postgres:
	$(SETUP); ./scripts/vm/install-postgres-vm.sh

openclaw-gateway gateway:
	$(SETUP); ./scripts/openclaw/openclaw-gateway.sh

openclaw-stop gateway-stop:
	$(SETUP); ./scripts/openclaw/openclaw-stop.sh

openclaw-tui tui:
	$(SETUP); ./scripts/openclaw/openclaw-tui.sh

openclaw-in-vm run:
	$(SETUP)
	./scripts/openclaw/openclaw-in-vm.sh "$(CMD)"

set-default-model model-set:
	$(SETUP)
	if [ -n "$(MODEL)" ]; then
		./scripts/openclaw/set-default-model.sh "$(MODEL)"
	else
		./scripts/openclaw/set-default-model.sh
	fi

peekaboo-status:
	$(SETUP); ./scripts/openclaw/peekaboo-status.sh

ssh-vm ssh:
	$(SETUP);./scripts/connect/ssh-vm.sh

copy-to-vm:
	$(SETUP)
	if [ -z "$(LOCAL_PATH)" ] || [ -z "$(REMOTE_PATH)" ]; then
		echo "Usage: make copy-to-vm LOCAL_PATH=./file REMOTE_PATH=~/Downloads/"
		exit 1
	fi
	./scripts/connect/copy-to-vm.sh "$(LOCAL_PATH)" "$(REMOTE_PATH)"

