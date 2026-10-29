# mcDETECT tutorial: MERSCOPE analysis (step by step)

This tutorial shows how to analyze **MERSCOPE** data with the **`mcDETECT`** package, following the workflow used in the mcDETECT repository. It covers:

- setting up `mcDETECT` from a transcript table;
- detecting RNA granules;
- measuring the gene expression of each granule;
- assigning granule subtypes **manually**;
- comparing **granule density** between WT and AD samples;
- finding **neuropil subdomains** in the Isocortex. This step uses a 50 × 50 µm grid, the proportion of each granule subtype in every grid spot, and K-Means clustering with k = 4.

**Package version:** mcDETECT **v2.1.6**.

**Main source files** (in the [mcDETECT repository](https://github.com/chen-yang-yuan/mcDETECT)): `mcDETECT_package/mcDETECT/model.py`, `mcDETECT_package/mcDETECT/downstream.py`, `code/3_detection.py`, `code/4_post_detection.ipynb`, `code/benchmark/benchmark_subtyping.ipynb`, `code/5_neuropil_subdomains_data.py`, `code/7_neuropil_subdomains.ipynb`.

---

## Analysis roadmap

1. [**Prepare**](./01_what_mcdetect_expects.md) — install mcDETECT and prepare the transcript table (coordinates, gene names, nucleus overlap, optional `cell_id`).
2. [**Initialize**](./02_construct_mcdetect.md) `mcDETECT` with the platform type, marker genes, and parameters.
3. [**Detect granules**](./03_granule_detection.md) — an optional rough run without filters, then the final run with filters.
4. [**Profile**](./04_profile_granules.md) — count the transcripts in each granule to build an `AnnData` count matrix, and combine the WT and AD samples.
5. [**Subtype manually**](./05_manual_subtyping.md) — cluster granules by marker-gene expression, inspect a heatmap, assign a biological label to each cluster, and group labels into pure and mixed types.
6. [**Compare density**](./06_density_wt_ad.md) — compare granule density between WT and AD in each brain region, using grid spots as spatial units.
7. [**Neuropil subdomains (Isocortex, 50×50)**](./07_neuropil_subdomains.md) — summarize granule subtypes per spot with `spot_embedding`, convert counts to proportions, and cluster spots with K-Means (k = 4).

See also the [quick reference checklist](./08_checklist.md).

Coordinate transformations specific to this dataset and the repeated runs over benchmark settings are not covered here.

---

## Pages

| File | Section |
|------|---------|
| [01_what_mcdetect_expects.md](./01_what_mcdetect_expects.md) | What mcDETECT expects |
| [02_construct_mcdetect.md](./02_construct_mcdetect.md) | Step A — Construct `mcDETECT` |
| [03_granule_detection.md](./03_granule_detection.md) | Step B — Granule detection |
| [04_profile_granules.md](./04_profile_granules.md) | Step C — Profile granules |
| [05_manual_subtyping.md](./05_manual_subtyping.md) | Step D — Manual granule subtyping |
| [06_density_wt_ad.md](./06_density_wt_ad.md) | Step E — WT vs AD density |
| [07_neuropil_subdomains.md](./07_neuropil_subdomains.md) | Step F — Neuropil subdomains (Isocortex) |
| [08_checklist.md](./08_checklist.md) | Quick reference checklist |

**Contributors:** instructions for publishing this site (not part of the website itself) are in **[`maintainer/PUBLISHING_READTHEDOCS.md`](https://github.com/chen-yang-yuan/mcDETECT-tutorial/blob/main/maintainer/PUBLISHING_READTHEDOCS.md)** in the **`mcDETECT-tutorial`** repository.
