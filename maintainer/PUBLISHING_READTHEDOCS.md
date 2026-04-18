# Publishing the tutorial (Read the Docs)

Tutorial **content** for the public site lives only in this repository under **`docs/tutorial_pages/`** (`README.md`, `01_*.md` …). Read the Docs builds from **`mcDETECT-tutorial`** on GitHub; there is **no** separate tutorial tree tracked in the **mcDETECT** repo.

This file is stored under **`maintainer/`** at the repo root so it is **not** part of the Sphinx project and does **not** appear on Read the Docs.

---

## Typical workflow

1. **Edit** Markdown in **`docs/tutorial_pages/`** (or add `09_*.md` and list it in **`docs/index.md`** `toctree`).
2. **Preview locally** (optional):

   ```bash
   make html
   # make open   # macOS
   ```

3. **Commit and push** this repository to **`main`**:

   ```bash
   git add docs/
   git commit -m "docs(tutorial): ..."
   git push origin main
   ```

Read the Docs rebuilds according to your project settings (usually on push to `main`).

---

## Adding a new page

1. Create **`docs/tutorial_pages/09_section_title.md`** (or similar).
2. Add a line to **`docs/index.md`** in the `toctree` block, **without** the `.md` suffix, e.g. `tutorial_pages/09_section_title`.

---

## Relationship to the mcDETECT codebase

The tutorial **documents** the **[mcDETECT](https://github.com/chen-yang-yuan/mcDETECT)** package; it does not need to live inside that repo. Code references in the text (e.g. `mcDETECT_package/mcDETECT/model.py`) point to paths **inside the mcDETECT repository** when users clone it.

---

## Historical note (removed)

Earlier setups copied from **`mcDETECT/tutorial/`** or used a **GitHub Action** to sync from **mcDETECT**. That flow is **no longer used**; editing **`docs/tutorial_pages/`** here is the single source of truth for the published tutorial.
