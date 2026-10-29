# 3. Step B — Granule detection (based on `3_detection.py`)

[← Tutorial index](./README.md)

### Step B1 — Load inputs

`3_detection.py` processes one sample at a time (e.g. `MERSCOPE_WT_1`, then `MERSCOPE_AD_1`):

```python
import pandas as pd

data_path = f"../data/{dataset}/processed_data/"
transcripts = pd.read_parquet(data_path + "transcripts.parquet")
genes = list(pd.read_csv(data_path + "genes.csv").iloc[:, 0])
nc_genes = list(pd.read_csv(data_path + "negative_controls.csv")["Gene"])
```

`syn_genes` is the list of 20 marker genes from [Section 2](./02_construct_mcdetect.md).

### Step B2 — Optional “rough” detection

**Goal:** Look at all candidate granules before any filtering by size, in-soma ratio, or negative controls.

**Actions:**

1. Create `mcDETECT` with **`nc_genes=None`**, **`size_thr=1e5`**, and **`in_soma_thr=1.01`**, which turns all three filters off.
2. Call **`sphere_dict = mc_rough.dbscan(record_cell_id=True)`**. Use `record_cell_id=True` only if you want a `cell_id` for each granule; this needs a `cell_id` column in `transcripts`.
3. Call **`granules_rough = mc_rough.merge_sphere(sphere_dict)`**.
4. Save or inspect **`granules_rough`** (`3_detection.py` saves it as `all_granules.parquet`).

```python
mc_rough = mcDETECT(
    type="discrete",
    transcripts=transcripts,
    gnl_genes=syn_genes,
    nc_genes=None,
    eps=1.5,
    minspl=3,
    grid_len=1,
    cutoff_prob=0.95,
    alpha=10,
    low_bound=3,
    size_thr=1e5,
    in_soma_thr=1.01,
    l=1,
    rho=0.2,
    s=1,
    nc_top=20,
    nc_thr=0.1,
)

sphere_dict = mc_rough.dbscan(record_cell_id=True)
granules_rough = mc_rough.merge_sphere(sphere_dict)
```

**Outputs:**

- **`sphere_dict`:** a dictionary with one table (`DataFrame`) per marker gene. The keys are 0, 1, 2, … in the order of `gnl_genes`; with `merge_genes=True` there is a single key, 0. Each table has these columns:

  | Column | Meaning |
  |--------|---------|
  | `sphere_x`, `sphere_y`, `sphere_z` | Center of the sphere. |
  | `layer_z` | The z-plane closest to the center. |
  | `sphere_r` | Radius of the sphere. |
  | `size` | Number of marker transcripts inside the sphere: the cluster's own transcripts plus transcripts of other marker genes within the radius. |
  | `comp` | Number of different marker genes inside the sphere. |
  | `in_soma_ratio` | Fraction of those transcripts that lie inside nuclei. |
  | `gene` | The marker gene whose cluster produced the sphere. |
  | `cell_id` | The most common `cell_id` among the sphere's transcripts (only with `record_cell_id=True`). |

- **`granules_rough`:** one table with the same columns, after overlapping spheres from different genes have been combined.

### Step B3 — “Fine” detection (recommended)

**Goal:** Keep only granules of realistic size, with few transcripts inside nuclei, that pass the negative-control filter.

**Action:** Create **`mc`** as in [Section 2, Step A3](./02_construct_mcdetect.md) (with **`nc_genes`**, **`size_thr=4.0`**, and **`in_soma_thr=0.1`**), then run:

```python
granules = mc.detect()
```

**What `detect()` does:** it runs `dbscan`, then `merge_sphere`, then `nc_filter` (the last only if `nc_genes` is not `None`). `nc_filter` counts the negative-control transcripts inside each sphere and adds the **`nc_ratio`** column.

| Method | Purpose | Output |
|--------|---------|---------------|
| `dbscan(target_names=None, record_cell_id=False)` | Runs 3D DBSCAN for each marker gene, fits a sphere around each cluster, and applies the size and in-soma filters | dictionary of tables |
| `merge_sphere(sphere_dict)` | Combines overlapping spheres from different marker genes (controlled by `l`, `rho`, `s`) | table |
| `nc_filter(sphere)` | Removes spheres with too many negative-control transcripts (controlled by `nc_top`, `nc_thr`) | table |
| `detect(record_cell_id=False)` | Runs all of the above | table |

### Step B4 — Optional region labels

If you have a spot `AnnData` with `global_x`, `global_y`, and `brain_area`, you can label each granule with the brain region of the nearest spot center. This is how `3_detection.py` does it:

```python
from scipy.spatial import cKDTree

tree = cKDTree(spots.obs[["global_x", "global_y"]].to_numpy())
_, nn_idx = tree.query(granules[["sphere_x", "sphere_y"]].to_numpy(), k=1)
granules["brain_area"] = spots.obs["brain_area"].to_numpy()[nn_idx]
granules.to_parquet(output_path + "granules.parquet")
```

`3_detection.py` also rotates the coordinates in a way specific to this dataset; that step is not shown here.

**Next:** [Step C — Profile granules](./04_profile_granules.md)
