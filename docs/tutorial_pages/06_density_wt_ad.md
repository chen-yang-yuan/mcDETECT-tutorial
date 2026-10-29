# 6. Step E — Granule density comparison WT vs AD (`benchmark_subtyping.ipynb`)

[← Tutorial index](./README.md)

For this step, each granule needs:

- a subtype label, **`granule_subtype_manual_simple`**;
- a **sample** label (`"WT"` or `"AD"`, e.g. `sample_simple` from [Step D1](./05_manual_subtyping.md));
- coordinates in the **same coordinate system as that sample's spots**.

The functions below read the coordinates from **`global_x` / `global_y`** in `obs` (the names used after `profile`). If those columns are missing, they use `sphere_x` / `sphere_y`.

### Step E1 — Load the spots for each sample

Load **`spots.h5ad`** for WT and AD separately. Each spot table must contain **`brain_area`** and the spot center coordinates **`global_x`** and **`global_y`** in `obs`. Always pair each sample's granules with **that sample's** spots, so that coordinates from different tissue sections are never mixed.

### Step E2 — How density is defined (50 µm spots)

The notebook function **`compute_subtype_density_per_region(granule_obs, spots, subtype_col="granule_subtype_manual_simple", sample_col=..., grid_len=50)`** computes density as follows:

- It works on each combination of **sample**, **brain region**, and **subtype**. It also adds an **`"overall"`** row that includes all granules.
  - For each spot in the region, it counts the granules that fall inside the 50 × 50 µm square centered on that spot.
  - **Density** = total count over all spots in the region / **number of spots** in the region.

Density is therefore the average number of granules per 50 × 50 µm spot. It is not a density per unit volume.

```python
density_wt = compute_subtype_density_per_region(obs_wt, spots_wt, sample_col="sample_simple")
density_ad = compute_subtype_density_per_region(obs_ad, spots_ad, sample_col="sample_simple")
```

### Step E3 — Correct AD for capture efficiency

Before comparing the samples, the notebook divides the AD densities, and the AD per-spot counts, by a fixed factor:

```python
CAPTURE_EFFICIENCY_COEF = 0.818691
density_ad["density"] = density_ad["density"] / CAPTURE_EFFICIENCY_COEF
```

Change or skip this correction if your study does not use it.

### Step E4 — Per-spot counts and statistics

**`compute_subtype_per_spot_counts`** takes the same arguments. It returns the granule count of every spot, with one row per sample, brain region, subtype, and spot. The notebook uses these per-spot counts in three ways:

- a **bootstrap 95% confidence interval** for the mean density;
- a two-sample **t-test** (`scipy.stats.ttest_ind`) on **`log1p(count)`**, comparing WT and AD for each brain region and subtype;
- **Bonferroni** and **Benjamini–Hochberg (FDR)** correction for multiple testing.

### Step E5 — Export

Save the density table as a CSV file, with one row per sample, brain region, and subtype, and columns for density, confidence interval, and p-values. Keep it with the subtype labels from [Step D5](./05_manual_subtyping.md).

**Next:** [Step F — Neuropil subdomains](./07_neuropil_subdomains.md)
