# This file is part of the dune-community/Dockerfiles project:
#   https://github.com/dune-community/Dockerfiles
# Copyright 2017 dune-community/Dockerfiles developers and contributors. All rights reserved.
# License: Dual licensed as BSD 2-Clause License (http://opensource.org/licenses/BSD-2-Clause)
#      or  GPL-2.0+ (http://opensource.org/licenses/gpl-license)
# Authors:
#   Rene Milk (2017)

SUBDIRS = manylinux arch debian gitlabci 
PUSH = $(addprefix push_,$(SUBDIRS))
README = $(addprefix readme_,$(SUBDIRS))
.PHONY: subdirs $(SUBDIRS) base push debian_*

THIS_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
include $(THIS_DIR)/rules.mk

subdirs: $(SUBDIRS)

$(SUBDIRS):
	make -C $@

debian_%:
	make -C debian $*

readme_%:
	make -C $* readme

arch_%:
	make -C arch $*

push: $(PUSH)

docker_readme:
	docker run -it -v $(THIS_DIR):/src docker:stable \
	    sh -c "apk --update add py3-pip m4 git file bash python3 curl make tar && make readme -C /src"

readme: $(README)

push_debian_ci:
	make -C debian ci_push
push_debian_unstable_ci:
	make -C debian unstable_ci_push

push_%: %
	make -C $< push

all: subdirs

dockerignore:
	find . -mindepth 2 -name .dockerignore  | xargs -I{} cp -f .dockerignore {}
