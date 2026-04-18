# mcDETECT-tutorial — Sphinx docs for Read the Docs
# Edit tutorial Markdown in docs/tutorial_pages/ (see maintainer/PUBLISHING_READTHEDOCS.md).

.DEFAULT_GOAL := help

BRANCH  := main
REMOTE  := origin
VENV    := .venv
SPHINX  := $(VENV)/bin/sphinx-build

.PHONY: help html clean open push check-branch status log

help:
	@echo "Workflow: edit docs/tutorial_pages/*.md → make html (optional) → git push"
	@echo "Maintainer instructions (not on RTD): maintainer/PUBLISHING_READTHEDOCS.md"
	@echo ""
	@echo "Targets:"
	@echo "  make html   - Sphinx HTML to docs/_build/html (creates $(VENV) if missing)"
	@echo "  make open   - open built site (macOS)"
	@echo "  make clean  - remove docs/_build"
	@echo "  make push   - stage all, commit with timestamp if needed, push $(REMOTE) $(BRANCH)"
	@echo "  make status / make log"

$(VENV)/bin/sphinx-build:
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install -q -r docs/requirements.txt

html: $(SPHINX)
	$(SPHINX) -b html docs docs/_build/html
	@echo "Built: docs/_build/html/index.html"

open: html
	@open docs/_build/html/index.html

clean:
	rm -rf docs/_build

check-branch:
	@CURRENT=$$(git branch --show-current); \
	if [ "$$CURRENT" != "$(BRANCH)" ]; then \
	  echo "On branch $$CURRENT (expected $(BRANCH))"; exit 1; \
	fi

TIMESTAMP := $(shell date "+%Y-%m-%d %H:%M:%S")

push: check-branch
	@git rev-parse --is-inside-work-tree >/dev/null 2>&1 || (echo "Not a git repository" && exit 1)
	git add -A
	@git diff --cached --quiet || git commit -m "Auto-commit: $(TIMESTAMP)"
	git push $(REMOTE) $(BRANCH)

status:
	@git status

log:
	@git --no-pager log --oneline -5
