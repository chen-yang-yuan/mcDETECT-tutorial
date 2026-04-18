# Syncing tutorial content from `mcDETECT`

Tutorial Markdown files are maintained in the **mcDETECT** repository under `tutorial/`. This docs site copies them into `docs/tutorial_pages/`.

- **Manual:** copy `README.md` and `01_*.md` … `08_*.md` from `mcDETECT/tutorial/` into `docs/tutorial_pages/` in this repo, then commit.
- **CI:** use `.github/workflows/sync-tutorial-from-mcdetect.yml` (workflow dispatch or push to `main`) to pull from the configured `mcDETECT` GitHub repository and rsync into `docs/tutorial_pages/`.

See the upstream note in the mcDETECT repo: `tutorial/readthedocs_github_action.md`.
