# Track-Ignored-Stuff - Makefile
# Common shortcuts for safe publishing and internal sync.

SHELL := /bin/bash

# Defaults (override at invocation: make publish PUBLIC_BRANCHES="main release/v1")
PUBLIC_REMOTE ?= origin-public
PUBLIC_BRANCHES ?= main
INTERNAL_REMOTE ?= origin-internal
INTERNAL_BRANCH ?= dev-internal
INTERNAL_DIR ?= __INTERNAL__

.PHONY: help init check-hook publish publish-main publish-branches sync-internal feature merge-into-main merge-from-main

help:
	@echo "Targets:"
	@echo "  make init                     # install pre-push hook (.githooks)"
	@echo "  make check-hook               # verify hook installed"
	@echo "  make publish                  # publish PUBLIC_BRANCHES to PUBLIC_REMOTE (filtering __INTERNAL__)"
	@echo "  make publish-main             # publish main only"
	@echo "  make publish-branches BRANCHES=\"main release/v1\""
	@echo "  make sync-internal            # subtree-push INTERNAL_DIR to INTERNAL_REMOTE/INTERNAL_BRANCH"
	@echo "  make feature name=my-feature  # create feature branch feat/my-feature"
	@echo "  make merge-into-main branch=feat/my-feature"
	@echo "  make merge-from-main          # merge main into current branch"

init:
	@mkdir -p .githooks
	@chmod +x .githooks/pre-push || true
	@git config core.hooksPath .githooks
	@echo "Installed hooksPath=.githooks"

check-hook:
	@test -x ./.githooks/pre-push && echo "pre-push hook found and executable" || (echo "pre-push hook missing or not executable" && exit 1)
	@git config core.hooksPath | grep -q ".githooks" && echo "hooksPath OK" || (echo "hooksPath not set to .githooks" && exit 1)

publish:
	@PUBLIC_REMOTE=$(PUBLIC_REMOTE) PUBLIC_BRANCHES="$(PUBLIC_BRANCHES)" INTERNAL_DIR="$(INTERNAL_DIR)" bash scripts/publish.sh

publish-main:
	@PUBLIC_REMOTE=$(PUBLIC_REMOTE) PUBLIC_BRANCHES="main" INTERNAL_DIR="$(INTERNAL_DIR)" bash scripts/publish.sh

publish-branches:
	@test -n "$(BRANCHES)" || (echo "Usage: make publish-branches BRANCHES=\"main release/v1\"" && exit 2)
	@PUBLIC_REMOTE=$(PUBLIC_REMOTE) PUBLIC_BRANCHES="$(BRANCHES)" INTERNAL_DIR="$(INTERNAL_DIR)" bash scripts/publish.sh

sync-internal:
	@INTERNAL_REMOTE=$(INTERNAL_REMOTE) INTERNAL_BRANCH=$(INTERNAL_BRANCH) INTERNAL_DIR="$(INTERNAL_DIR)" bash scripts/sync-internal.sh

feature:
	@test -n "$(name)" || (echo "Usage: make feature name=my-feature" && exit 2)
	@git checkout -b "feat/$(name)"

merge-into-main:
	@branch=$(branch); if [ -z "$$branch" ]; then branch=$$(git rev-parse --abbrev-ref HEAD); fi; \
	git checkout main && git merge --no-ff "$$branch"

merge-from-main:
	@cur=$$(git rev-parse --abbrev-ref HEAD); git fetch origin --prune; git merge --no-ff main
