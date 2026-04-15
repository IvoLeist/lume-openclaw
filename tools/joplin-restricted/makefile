SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ENV_FILE ?= $(ROOT_DIR).env
ENV_FILE_FOR_DOCKER ?= .env.docker
ARGS ?=
TITLE ?=
BODY ?=

UV_RUN := uv run --env-file $(ENV_FILE) joplin_api_wrapper.py $(ARGS)

DOCKER_IMAGE := joplin-restricted:latest

DOCKER_RUN := docker run --rm \
	--env-file $(ENV_FILE_FOR_DOCKER) \
	--network host \
	--read-only \
	--tmpfs /tmp \
	$(DOCKER_IMAGE)


.DEFAULT_GOAL := help

.PHONY: help sync install run get-notebook-id list-notes create-note

help:
	printf '%s\n' \
			'Available targets:' \
			'  make sync' \
			'  make install' \
			'  make run ARGS="list-notes"' \
			'  make get-notebook-id' \
			'  make list-notes' \
			'  make create-note TITLE="..." BODY="..."'
	printf '%s\n' \
			'' \
			'Environment:' \
			'  JOPLIN_BASE_URL' \
			'  JOPLIN_API_TOKEN'

sync:
	uv sync

install: sync

notebook-id:
	$(UV_RUN) get-notebook-id

list:
	$(UV_RUN) list-notes

create:
	if [ -z "$(TITLE)" ] || [ -z "$(BODY)" ]; \
		then echo 'Usage: make create-note TITLE="..." BODY="..."';\
		exit 1; fi
	$(UV_RUN) create-note "$(TITLE)" "$(BODY)"

build-image:
	docker build -t $(DOCKER_IMAGE) .

d-get-notebook-id:
	$(DOCKER_RUN) get-notebook-id

d-list-notes:
	$(DOCKER_RUN) list-notes