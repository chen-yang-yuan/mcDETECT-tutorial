# mcDETECT-tutorial

Published documentation for the **[mcDETECT](https://github.com/chen-yang-yuan/mcDETECT)** MERSCOPE tutorial (Markdown sources live in that repo under `tutorial/`).

- **Read the Docs:** configure the project to use `.readthedocs.yaml` at the repository root and `docs/requirements.txt` for dependencies.
- **Local build:**

  ```bash
  python -m venv .venv && source .venv/bin/activate
  pip install -r docs/requirements.txt
  sphinx-build -b html docs docs/_build/html
  ```

  Open `docs/_build/html/index.html` in a browser.

- **Sync from upstream:** run the GitHub Action **“Sync tutorial from mcDETECT”** (workflow dispatch), or copy `tutorial/*.md` from mcDETECT into `docs/tutorial_pages/` manually. See `docs/maintainers/sync_from_mcdetect.md`.
