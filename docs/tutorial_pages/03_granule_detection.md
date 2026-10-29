# 3. Step B — Granule detection (pattern from `3_detection.py`)

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

`syn_genes` is the 20-marker list from [Section 2](./02_construct_mcdetect.md).

### Step B2 — Optional “rough” detection

**Goal:** See candidate granules without size, in-soma, or NC filtering.

**Actions:**

1. Build `mcDETECT` with **`nc_genes=None`**, **`size_thr=1e5`**, **`in_soma_thr=1.01`**.
2. Call **`sphere_dict = mc_rough.dbscan(record_cell_id=True)`** if you need per-sphere `cell_id` (requires a `cell_id` column in `transcripts`).
3. Call **`granules_rough = mc_rough.merge_sphere(sphere_dict)`**.
4. Save or inspect **`granules_rough`** (`3_detection.py` writes `all_granules.parquet`).

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

**Output shapes:**

- **`sphere_dict`:** `dict[int, pandas.DataFrame]`, keyed by the position of each marker in `gnl_genes` (a single key `0` when `merge_genes=True`). Columns:

  | Column | Meaning |
  |--------|---------|
  | `sphere_x`, `sphere_y`, `sphere_z` | Center of the minimum enclosing sphere. |
  | `layer_z` | Nearest z-plane to the center. |
  | `sphere_r` | Radius. |
  | `size` | Number of granule-marker transcripts inside the sphere (the cluster's own transcripts plus other markers' transcripts within the radius). |
  | `comp` | Number of distinct marker genes inside the sphere. |
  | `in_soma_ratio` | Fraction of those transcripts with `overlaps_nucleus`. |
  | `gene` | Marker gene that seeded the sphere. |
  | `cell_id` | Modal `cell_id` (only with `record_cell_id=True`). |

- **`granules_rough`:** a single **`DataFrame`** with the same columns after the cross-gene merge.

### Step B3 — “Fine” detection (recommended)

**Goal:** Spheres with realistic maximum radius, low in-soma contamination, and NC filtering.

**Action:** Build **`mc`** as in [Section 2, Step A3](./02_construct_mcdetect.md) (with **`nc_genes`**, **`size_thr=4.0`**, **`in_soma_thr=0.1`**), then:

```python
granules = mc.detect()
```

**Internal pipeline:** `dbscan` → `merge_sphere` → `nc_filter` (only if `nc_genes` is not `None`). `nc_filter` adds an **`nc_ratio`** column and counts NC transcripts around each sphere's (`sphere_x`, `sphere_y`, `layer_z`) center.

| Method | Purpose | Main output |
|--------|---------|---------------|
| `dbscan(target_names=None, record_cell_id=False)` | 3D DBSCAN per marker, minimum enclosing sphere, size and in-soma filters | `dict[int, DataFrame]` |
| `merge_sphere(sphere_dict)` | Resolve overlaps between spheres from different markers (`l`, `rho`, `s`) | `DataFrame` |
| `nc_filter(sphere)` | Negative-control filter (`nc_top`, `nc_thr`) | `DataFrame` |
| `detect(record_cell_id=False)` | Full pipeline | `DataFrame` |

### Step B4 — Optional region labels

If you have a spot `AnnData` with `global_x`, `global_y`, and `brain_area`, assign each granule the region of its nearest spot center before saving. This is the pattern in `3_detection.py`:

```python
from scipy.spatial import cKDTree

tree = cKDTree(spots.obs[["global_x", "global_y"]].to_numpy())
_, nn_idx = tree.query(granules[["sphere_x", "sphere_y"]].to_numpy(), k=1)
granules["brain_area"] = spots.obs["brain_area"].to_numpy()[nn_idx]
granules.to_parquet(output_path + "granules.parquet")
```

Dataset-specific coordinate rotations in `3_detection.py` are omitted.

**Next:** [Step C — Profile granules](./04_profile_granules.md)
