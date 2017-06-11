#!/bin/bash

# ===========================================================
# Author:   Marcos Lin
# Created:	8 Jun 2017
#
# Makefile used to setup GAE Rest Seed Application
#
# ===========================================================

PROJ_DIR           := $(shell pwd)
CONFIG_DIR         := $(PROJ_DIR)/config
SSH_DIR         := $(PROJ_DIR)/ssh
DOCKER_BUILD_CHECK := $(CONFIG_DIR)/docker.built
DOCKER_IMAGE       := farport/gae-python2-dev
DOCKER_IMAGE_NAME  := gae-devserver
DOCKER_IMAGE_ID    = $(shell docker ps -aqf"name=$(DOCKER_IMAGE_NAME)")


# ------------------
# USAGE: First target called if no target specified
man :
	@cat README.md


# ------------------
# Check dependencies
init :
ifeq ($(shell which docker),)
	$(error docker command needed to be installed.)
endif
ifeq ($(shell which curl),)
	$(error curl command needed to be installed.)
endif


# ------------------
# MAIN TARGETS
$(DOCKER_BUILD_CHECK) : 
	docker build -f Dockerfile -t $(DOCKER_IMAGE) .
	touch $@

setup : init $(DOCKER_BUILD_CHECK)
	@echo "Docker image $(DOCKER_IMAGE) built"

$(SSH_DIR) :
	mkdir $@
	chmod 700 $@

$(CONFIG_DIR) :
	mkdir $@

run : setup $(CONFIG_DIR) $(SSH_DIR)
ifeq ($(DOCKER_IMAGE_ID),)
	@echo "### Running docker image"
	@docker run -p8000:8000 -p8080:8080 -v $(CONFIG_DIR):/root/.config -v $(SSH_DIR):/root/.ssh --name $(DOCKER_IMAGE_NAME) -it $(DOCKER_IMAGE)
else
	@echo "### Staring docker image"
	@docker start -i $(DOCKER_IMAGE_ID)
endif

clean :
ifneq ($(DOCKER_IMAGE_ID),)
	@echo "### Removing docker container"
	@docker rm $(DOCKER_IMAGE_ID)
	@docker rmi $(DOCKER_IMAGE)
endif
	rm $(DOCKER_BUILD_CHECK)

# ------------------
# DEFINE PHONY TARGET: Basically all targets
.PHONY : \
	man init setup run clean
