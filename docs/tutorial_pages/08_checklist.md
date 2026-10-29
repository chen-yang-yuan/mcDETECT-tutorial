# 8. Quick reference checklist

[← Tutorial index](./README.md)

| Step | Action |
|------|--------|
| 1 | Install mcDETECT; build `transcripts` with required columns ([Section 1](./01_what_mcdetect_expects.md)). |
| 2 | Instantiate `mcDETECT` using the numbered parameter list ([Section 2](./02_construct_mcdetect.md)). |
| 3 | Optional rough pass (`dbscan` → `merge_sphere`), then fine `detect()`; add `brain_area` per granule ([Section 3](./03_granule_detection.md)). |
| 4 | `profile` → `granule_adata`; keep `layers["counts"]`; combine WT + AD ([Section 4](./04_profile_granules.md)). |
| 5 | Restrict to marker genes → MiniBatch k-means (k = 15) → heatmap → `apply_manual_annotation` ([Section 5](./05_manual_subtyping.md)). |
| 6 | WT/AD density in 50 µm spot windows, optional AD calibration, statistics, export ([Section 6](./06_density_wt_ad.md)). |
| 7 | Isocortex, 50×50, `spot_embedding` (hard), row-normalize, K-Means **k = 4** ([Section 7](./07_neuropil_subdomains.md)). |

This tutorial follows **mcDETECT v2.1.6** (`mcDETECT_package/mcDETECT/model.py`, `downstream.py`) and the analysis order in **`3_detection.py`** → **`4_post_detection.ipynb`** → **`benchmark/benchmark_subtyping.ipynb`** → **`5_neuropil_subdomains_data.py`** → the **Isocortex / 50×50 / hard-normalized / k = 4** branch of **`7_neuropil_subdomains.ipynb`**.
