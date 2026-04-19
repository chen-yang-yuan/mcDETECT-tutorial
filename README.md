# mcDETECT Tutorial

Published **[Read the Docs](https://readthedocs.org/)** site for the **[mcDETECT](https://github.com/chen-yang-yuan/mcDETECT)** MERSCOPE tutorial.

## Editing the tutorial

**Source of truth:** Markdown under `**docs/tutorial_pages/`** in **this** repository (`README.md`, `01_*.md` …). Edit there, then commit and push `**main`**; Read the Docs rebuilds.

**Instructions (not shown on RTD):** `[maintainer/PUBLISHING_READTHEDOCS.md](maintainer/PUBLISHING_READTHEDOCS.md)`

## Local preview

```bash
make html          # Sphinx → docs/_build/html
make open          # macOS: open index.html
```

Dependencies: `docs/requirements.txt` (installed automatically into `.venv` by `make html`).

## Read the Docs

Configuration: `**.readthedocs.yaml**` at the repo root, `**docs/requirements.txt**` for Python deps.

## Makefile

```bash
make help          # list targets
make push          # commit (if needed) and push origin main
```

