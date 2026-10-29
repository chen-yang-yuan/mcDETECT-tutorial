# 7. Step F — Neuropil subdomain analysis, Isocortex (`7_neuropil_subdomains.ipynb`)

[← Tutorial index](./README.md)

This page describes the settings used for the final results:

- region: **Isocortex**;
- spot size: **50 × 50 µm**;
- each granule is assigned to exactly one spot (`spot_embedding`);
- spots are described by the **proportion** of each granule subtype;
- spots are clustered with **K-Means, k = 4**.

The notebook also tries other options, such as 25 × 25 µm spots, other clustering methods, and k = 5. These are not covered here.

### Step F1 — Region and grid settings

```python
ROI = "Isocortex"
grid_len = "50_by_50"
grid_len_num = 50
```

### Step F2 — Inputs (prepared by `5_neuropil_subdomains_data.py`)

`5_neuropil_subdomains_data.py` moves the WT and AD samples into one shared coordinate system. You need these objects:

- **`granule_adata`** — the combined granule object from [Step C5](./04_profile_granules.md), with the **`granule_subtype_kmeans`** labels from [Step D](./05_manual_subtyping.md) in `obs` and raw counts in **`layers["counts"]`**.
- **`adata`** — the combined cell-level `AnnData`.
- **`spots`** — the combined WT + AD 50 × 50 µm spots in the Isocortex, with **`global_x`**, **`global_y`**, and **`layer_labels`** in `obs`.
- **`count_matrix`** — a table of gene counts per cell, with a **`cell_id`** column and gene columns in the same order as **`granule_adata.var_names`**.

**Select neurons** (used to count neurons per spot):

```python
adata_neuron = adata[adata.obs["brain_area"].str.startswith(ROI)
                     & adata.obs["cell_type"].isin(["GABAergic", "Glutamatergic"])].copy()
```

### Step F3 — Count granule subtypes per spot (`spot_embedding`)

Call **`spot_embedding`** from **`mcDETECT.downstream`**. Here it assigns each granule and neuron to one 50 × 50 µm spot, smooths the subtype counts across neighboring spots, and also counts neurons:

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

**What the outputs contain:**

- **Spot assignment:** each granule (and each neuron) is assigned to the one spot whose 50 × 50 µm square contains it.
- **`embeddings`** — a matrix with one row per spot and one column per k-means cluster, giving the number of granules of each cluster in the spot. With `smoothing=True`, only this matrix is smoothed. Each spot's counts are replaced by a weighted average of its own counts and those of its 8 surrounding spots, with closer spots weighted more.
- **`aux_features`** — the number of granules (`granule_count`) and neurons (`soma_count`) in each spot.
- **`spot_granule_expression`** / **`spot_cell_expression`** — gene counts per spot, summed over the granules and over the neurons in that spot.

### Step F4 — Remove spots without granules

```python
mask = (spots.obs["granule_count"] > 0).to_numpy()
spots = spots[mask].copy()
embeddings = embeddings[mask].copy()
spot_granule_expression = spot_granule_expression[mask].copy()
spot_cell_expression = spot_cell_expression[mask].copy()
```

### Step F5 — Convert counts to proportions

Divide each row of **`embeddings`** by its sum, so each spot is described by the proportion of granules in each subtype:

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

The notebook also renumbers the subdomains so that they appear in the same order in all figures. This does not change the clustering.

### Step F7 — Visualization and follow-up analyses (optional)

- **Spatial map:** plot the spots (`global_x`, `global_y`) colored by **`subdomain_kmeans`**.
- **Subtype heatmap:** plot the average of **`X`** for each subdomain and granule cluster, to see which granule subtypes characterize each subdomain.
- **Differential expression between subdomains:** make an `AnnData` from `spot_granule_expression` or `spot_cell_expression`, run `normalize_total` and `log1p`, then run `sc.tl.rank_genes_groups`. The notebook compares Subdomain 1 with Subdomain 2 using `method="wilcoxon"`.

**Next:** [Quick reference checklist](./08_checklist.md)
