# 6. Step E — Granule density comparison WT vs AD (`benchmark_subtyping.ipynb`)

[← Tutorial index](./README.md)

This step assumes each granule has **`granule_subtype_manual_simple`**, a **sample** column (`"WT"` / `"AD"`, e.g. `sample_simple` from [Step D1](./05_manual_subtyping.md)), and coordinates in the **same frame as that sample's spots**. The helpers use **`global_x` / `global_y`** in `obs` (after `profile`) and fall back to `sphere_x` / `sphere_y`.

### Step E1 — Spatial reference: spots per sample

Load **`spots.h5ad`** for WT and AD separately. Each must have **`brain_area`** and spot centers **`global_x`**, **`global_y`** in `obs`. Pass each sample's granules together with **that sample's** spots, so coordinates are never mixed across sections.

### Step E2 — Density definition (50 µm windows)

The notebook helper **`compute_subtype_density_per_region(granule_obs, spots, subtype_col="granule_subtype_manual_simple", sample_col=..., grid_len=50)`** works as follows:

- For each **sample**, each **brain_area**, and each **subtype** (plus an **`"overall"`** row for all granules):
  - For every spot in that area, it counts granules whose (x, y) lies in the half-open square `[x − 25, x + 25) × [y − 25, y + 25)` around the spot center (half-width `grid_len / 2`).
  - **Density** = (sum of those counts) / (**number of spots** in that brain area).

Density is therefore the mean number of granules per 50 × 50 µm spot, not a volume density.

```python
density_wt = compute_subtype_density_per_region(obs_wt, spots_wt, sample_col="sample_simple")
density_ad = compute_subtype_density_per_region(obs_ad, spots_ad, sample_col="sample_simple")
```

### Step E3 — AD capture-efficiency correction

The notebook divides **AD** densities and AD per-spot counts by a fixed factor before any comparison:

```python
CAPTURE_EFFICIENCY_COEF = 0.818691
density_ad["density"] = density_ad["density"] / CAPTURE_EFFICIENCY_COEF
```

Adjust or omit this if your study does not use the calibration.

### Step E4 — Per-spot counts and statistics

**`compute_subtype_per_spot_counts`** takes the same arguments and returns one row per (sample, brain_area, subtype, spot) with that spot's granule count. The notebook uses these per-spot counts for a **bootstrap 95% CI** of mean density and a two-sample **t-test** (`scipy.stats.ttest_ind`) on **`log1p(count)`** between WT and AD per (brain_area, subtype). It then applies **Bonferroni** and **Benjamini–Hochberg FDR** correction.

### Step E5 — Export

Save the density table (one row per sample, brain_area, and subtype, with density, CI, and p-values) as CSV alongside the subtype labels from [Step D5](./05_manual_subtyping.md).

**Next:** [Step F — Neuropil subdomains](./07_neuropil_subdomains.md)
