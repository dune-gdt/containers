# This file is part of the dune-community/Dockerfiles project:
#   https://github.com/dune-community/Dockerfiles
# Copyright 2017 dune-community/Dockerfiles developers and contributors. All rights reserved.
# License: Dual licensed as BSD 2-Clause License (http://opensource.org/licenses/BSD-2-Clause)
#      or  GPL-2.0+ (http://opensource.org/licenses/gpl-license)
# Authors:
#   Rene Milk (2017)

SUBDIRS = manylinux arch debian gitlabci

.PHONY: subdirs $(SUBDIRS) base push

subdirs: $(SUBDIRS)

$(SUBDIRS):
	make -C $@

push: push_debian push_gitlabci

push_%: %
	make -C $<

all: subdirs