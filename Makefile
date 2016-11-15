MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

################
# Utilities

# Used for backups
date := $(shell date +%Y%m%d%H%M%S)

# Used for debugging
.PHONY: echo.%
echo.%:
	@echo $*=$($*)

# Used to make specific .env files
make-env = ./scripts/env.bash subst < $< > $@

# Used to load specific .env files
load-env = set -o allexport && unset $$(./scripts/env.bash variables) && source $< && set +o allexport

################
# Environment variables

ifndef PYTHON
PYTHON := python3
endif

################
# Sanity checks and local variables

ifndef VIRTUAL_ENV
$(error Not inside a virtual environment)
endif

################
# Exported variables

export DATE := $(date)

################
# Includes

################
# Standard targets

.PHONY: all
all: run

.PHONY: run
run: .depend.secondary .migrate.secondary
	$(PYTHON) manage.py runserver 8808

.PHONY: depend
depend: .depend.secondary

.PHONY: check
check:

.PHONY: clean
clean:
	find . -name '*~' -print -delete

################
# Application specific targets

################
# Source transformations

.migrate.secondary: server/settings.py
	$(PYTHON) manage.py makemigrations
	$(PYTHON) manage.py migrate

.depend.secondary: requirements.txt
	$(PYTHON) -m pip install -r requirements.txt
	touch $@

.env: .env.base
	touch $@
	cp $@ $@.$(date)
	./scripts/env.bash merge $@.$(date) $< > $@

.env.makefile: .env
	./scripts/env.bash to-makefile > $@
