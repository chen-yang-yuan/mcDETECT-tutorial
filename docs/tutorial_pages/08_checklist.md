# 8. Quick reference checklist

[← Tutorial index](./README.md)

| Step | Action |
|------|--------|
| 1 | Install mcDETECT and prepare the `transcripts` table with the required columns ([Section 1](./01_what_mcdetect_expects.md)). |
| 2 | Create the `mcDETECT` object, using the parameter list as a guide ([Section 2](./02_construct_mcdetect.md)). |
| 3 | Optionally run a rough detection (`dbscan`, then `merge_sphere`), then the final detection with `detect()`; label each granule with its brain region ([Section 3](./03_granule_detection.md)). |
| 4 | Run `profile` to get `granule_adata`, save raw counts in `layers["counts"]`, and combine WT and AD ([Section 4](./04_profile_granules.md)). |
| 5 | Keep the marker genes, run MiniBatch k-means (k = 15), inspect the heatmap, and assign labels with `apply_manual_annotation` ([Section 5](./05_manual_subtyping.md)). |
| 6 | Compute WT and AD density in 50 µm spots, optionally correct AD for capture efficiency, run the statistics, and export ([Section 6](./06_density_wt_ad.md)). |
| 7 | In the Isocortex with 50 × 50 µm spots, run `spot_embedding`, convert counts to proportions, and cluster with K-Means (k = 4) ([Section 7](./07_neuropil_subdomains.md)). |

This tutorial follows **mcDETECT v2.1.6** (`mcDETECT_package/mcDETECT/model.py`, `downstream.py`). The analysis order is: **`3_detection.py`**, **`4_post_detection.ipynb`**, **`benchmark/benchmark_subtyping.ipynb`**, **`5_neuropil_subdomains_data.py`**, and the Isocortex, 50 × 50 µm, k = 4 analysis in **`7_neuropil_subdomains.ipynb`**.
