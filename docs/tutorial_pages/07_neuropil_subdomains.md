# 7. Step F — Neuropil subdomain analysis, Isocortex (`7_neuropil_subdomains.ipynb`)

[← Tutorial index](./README.md)

The following is the setting used for the final results: **Isocortex**, **50×50** µm grids, **hard** `spot_embedding`, **row-normalized** subtype embedding, **K-Means with k = 4**. This page omits the other variants: soft embeddings, 25×25 grids, unnormalized embeddings, inertia/ARI sweeps, LDA/GMM/MiniBatch clustering, and **k = 5**.

### Step F1 — Region and grid constants

```python
ROI = "Isocortex"
grid_len = "50_by_50"
grid_len_num = 50
```

### Step F2 — Inputs (prepared by `5_neuropil_subdomains_data.py`)

`5_neuropil_subdomains_data.py` places WT and AD in one shared coordinate frame. You need these objects:

- **`granule_adata`** — the combined granule object from [Step C5](./04_profile_granules.md) with **`granule_subtype_kmeans`** from [Step D](./05_manual_subtyping.md) in `obs` and raw counts in **`layers["counts"]`**.
- **`adata`** — the combined cell-level `AnnData`.
- **`spots`** — the combined WT + AD 50×50 spot `AnnData` for the Isocortex, with **`global_x`**, **`global_y`**, and **`layer_labels`** in `obs`.
- **`count_matrix`** — a per-cell gene-count `DataFrame` with a **`cell_id`** column and gene columns aligned to **`granule_adata.var_names`**.

**Neurons for soma features:**

```python
adata_neuron = adata[adata.obs["brain_area"].str.startswith(ROI)
                     & adata.obs["cell_type"].isin(["GABAergic", "Glutamatergic"])].copy()
```

### Step F3 — Hard embedding (`spot_embedding`)

Call **`spot_embedding`** from **`mcDETECT.downstream`** with hard assignment to 50×50 windows, Gaussian smoothing, and soma features:

```python
import numpy as np
from mcDETECT.downstream import spot_embedding

embeddings, embeddings_features, aux_features, spot_granule_expression, spot_cell_expression = spot_embedding(
    spots=spots,
    granule_adata=granule_adata,
    adata=adata_neuron,
    count_matrix=count_matrix,
    spot_loc_key=("global_x", "global_y"),
    spot_width=grid_len_num,
    spot_height=grid_len_num,
    granule_loc_key=("global_x", "global_y"),
    granule_subtype_key="granule_subtype_kmeans",
    subtype_names=[str(i) for i in range(granule_adata.obs["granule_subtype_kmeans"].nunique())],
    granule_count_layer="counts",
    cell_loc_key=("global_x", "global_y"),
    cell_id_key="cell_id",
    count_matrix_cell_id_key="cell_id",
    include_soma_features=True,
    smoothing=True,
    smoothing_radius=np.sqrt(2) * grid_len_num + 1,
    smoothing_mode="gaussian",
)

for aux_key, aux_val in aux_features.items():
    spots.obs[aux_key] = aux_val
```

**What each output contains:**

- **Assignment:** each granule (and each neuron) goes to **one** spot, the one whose `spot_width × spot_height` square around the center contains it.
- **`embeddings`** — `n_spots × K` array of granule counts per **k-means cluster** (one column per `subtype_names` entry). With `smoothing=True`, only this matrix is smoothed: each spot becomes a Gaussian-weighted average of the spots within `smoothing_radius`, which here means the spot and its 8 neighbors.
- **`aux_features`** — `granule_count` and `soma_count` per spot.
- **`spot_granule_expression`** / **`spot_cell_expression`** — spot × gene sums of granule and neuron raw counts.

### Step F4 — Drop spots without granules

```python
mask = (spots.obs["granule_count"] > 0).to_numpy()
spots = spots[mask].copy()
embeddings = embeddings[mask].copy()
spot_granule_expression = spot_granule_expression[mask].copy()
spot_cell_expression = spot_cell_expression[mask].copy()
```

### Step F5 — Row-normalize the embedding

Normalize **each row** of **`embeddings`** to sum to 1, giving the subtype composition of each spot:

```python
row_sums = embeddings.sum(axis=1, keepdims=True)
X = np.divide(embeddings, row_sums, out=np.zeros_like(embeddings, dtype=float), where=row_sums > 0)
```

### Step F6 — K-Means with **k = 4**

```python
from sklearn.cluster import KMeans

n_clusters = 4
kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=20)
kmeans_labels = kmeans.fit_predict(X)
spots.obs["subdomain_kmeans"] = [f"Subdomain {l + 1}" for l in kmeans_labels]
```

The full notebook optionally **relabels** the subdomains so their order is consistent across figures; this is cosmetic.

### Step F7 — Visualization and follow-ups (optional)

- **Spatial maps:** scatter of `spots` (`global_x`, `global_y`) colored by **`subdomain_kmeans`**.
- **Composition heatmap:** the mean of **`X`** per subdomain × granule cluster, showing which granule subtypes define each subdomain.
- **Differential expression between subdomains:** build an `AnnData` from `spot_granule_expression` or `spot_cell_expression`, apply `normalize_total` and `log1p`, and run `sc.tl.rank_genes_groups` (the notebook uses `method="wilcoxon"` for Subdomain 1 vs Subdomain 2).

**Next:** [Quick reference checklist](./08_checklist.md)
