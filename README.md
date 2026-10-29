# mcDETECT Tutorial

Source for the **[mcDETECT tutorial](https://mcdetect-tutorial.readthedocs.io/en/latest/)** on Read the Docs, covering the **[mcDETECT](https://github.com/chen-yang-yuan/mcDETECT)** package.

## Editing the tutorial

The tutorial pages are the Markdown files in `docs/tutorial_pages/` in this repository (`README.md`, `01_*.md`, …). Edit them there, then commit and push to `main`. Read the Docs then rebuilds the website automatically.

**Publishing instructions (not shown on the website):** [maintainer/PUBLISHING_READTHEDOCS.md](maintainer/PUBLISHING_READTHEDOCS.md)

## Local preview

```bash
make html          # Sphinx → docs/_build/html
make open          # macOS: open index.html
```

Dependencies: `docs/requirements.txt` (installed automatically into `.venv` by `make html`).

## Read the Docs

The build is configured in `.readthedocs.yaml` (in the repository root). The required Python packages are listed in `docs/requirements.txt`.

## Makefile

```bash
make help          # list targets
make push          # commit (if needed) and push origin main
```
