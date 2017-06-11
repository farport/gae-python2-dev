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
RES_DIR            := $(PROJ_DIR)/res
GCLOUD_SDK         := google-cloud-sdk-158.0.0-linux-x86_64.tar.gz
GCLOUD_URL         := https://dl.google.com/dl/cloudsdk/channels/rapid/downloads
GCLOUD_OUT         := google-cloud-sdk.tar.gz
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
$(RES_DIR) :
	mkdir $@

$(CONFIG_DIR) :
	mkdir $@

$(RES_DIR)/$(GCLOUD_OUT) : $(RES_DIR)
	curl $(GCLOUD_URL)/$(GCLOUD_SDK) --output $@

$(DOCKER_BUILD_CHECK) : $(RES_DIR)/$(GCLOUD_OUT) $(CONFIG_DIR)
	docker build -f Dockerfile -t $(DOCKER_IMAGE) .
	touch $@

setup : init $(DOCKER_BUILD_CHECK)
	@echo "Docker image $(DOCKER_IMAGE) built"

run : setup
ifeq ($(DOCKER_IMAGE_ID),)
	@echo "### Running docker image"
	@docker run -p8000:8000 -p8080:8080 -v $(CONFIG_DIR):/.config -i -t --name $(DOCKER_IMAGE_NAME) $(DOCKER_IMAGE) 
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
