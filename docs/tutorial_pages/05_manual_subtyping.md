# 5. Step D — Manual granule subtyping (`benchmark_subtyping.ipynb`)

[← Tutorial index](./README.md)

The main result is annotated **manually**: k-means on marker-gene expression, a heatmap, then a hand-written mapping from clusters to biology. The package also has a rule-based classifier (`mcDETECT.downstream.classify_granules` / `GranuleSubtyper`). The notebook uses it only to tune automatic labels against the manual ones, so it is not covered here.

### Step D1 — Load and normalize

Start from the combined WT + AD object from [Step C5](./04_profile_granules.md). It is already normalized (`normalize_total(target_sum=1e4)` → `log1p`), with raw counts in `layers["counts"]`. Rename the sample column and keep only the reference marker genes:

```python
import scanpy as sc

ref_genes = ["Bsn", "Gap43", "Nrxn1", "Slc17a6", "Slc17a7", "Slc32a1", "Stx1a", "Syn1", "Syp", "Syt1", "Vamp2", "Cplx2",
             "Camk2a", "Dlg3", "Dlg4", "Gphn", "Gria1", "Gria2", "Homer1", "Homer2", "Nlgn1", "Nlgn2", "Nlgn3", "Shank1", "Shank3",
             "Cyfip2", "Ddn", "Map1a", "Map2", "Ank3", "Nav1", "Nfasc", "Mapt", "Tubb3"]

granule_adata = sc.read_h5ad("granule_adata_tsne.h5ad")    # combined WT + AD object
granule_adata.obs.rename(columns={"batch": "sample"}, inplace=True)
granule_adata.obs["sample_simple"] = granule_adata.obs["sample"].replace({"MERSCOPE_WT_1": "WT", "MERSCOPE_AD_1": "AD"})
granule_adata = granule_adata[:, ref_genes].copy()
```

If you start from raw per-sample profiles instead, concatenate WT and AD and restrict them to the shared marker genes. Then store `layers["counts"]` and apply `sc.pp.normalize_total(target_sum=1e4)` and `sc.pp.log1p` before clustering.

### Step D2 — MiniBatch k-means

The main result uses **`n_clusters=15`**, **`seed=1`**, **`batch_size=5000`**, **`n_init=20`**, fit on the log-normalized marker matrix (densified if sparse):

```python
import numpy as np
import pandas as pd
from sklearn.cluster import MiniBatchKMeans

def run_manual_subtyping(granule_adata, n_clusters, seed, batch_size=5000, n_init=20, obs_key="granule_subtype_kmeans"):
    data = granule_adata.X.copy()
    if hasattr(data, "toarray"):
        data = data.toarray()
    np.random.seed(seed)
    kmeans = MiniBatchKMeans(n_clusters=n_clusters, batch_size=batch_size, random_state=seed, n_init=n_init)
    kmeans.fit(data)
    granule_adata.obs[obs_key] = kmeans.labels_.astype(str)
    granule_adata.obs[obs_key] = pd.Categorical(
        granule_adata.obs[obs_key],
        categories=[str(i) for i in range(n_clusters)],
        ordered=True,
    )
    return granule_adata

granule_adata = run_manual_subtyping(granule_adata, n_clusters=15, seed=1)
```

**Output:** **`obs["granule_subtype_kmeans"]`** — string cluster ids `"0"` … `"14"`. Cluster ids depend on the seed, so the mapping in Step D4 is only valid for the same data, seed, and settings.

### Step D3 — Heatmap-driven biology

Plot the marker genes per cluster and decide which clusters look pre-synaptic, post-synaptic, dendritic, or mixed:

```python
sc.pl.heatmap(granule_adata, var_names=ref_genes, groupby="granule_subtype_kmeans",
              cmap="Reds", standard_scale="var", dendrogram=False, swap_axes=True)
```

The notebook groups the markers as follows:

| Category | Markers |
|----------|---------|
| pre-syn | Bsn, Gap43, Nrxn1, Slc17a6, Slc17a7, Slc32a1, Snap25, Stx1a, Syn1, Syp, Syt1, Vamp2, Cplx2 |
| post-syn | Camk2a, Dlg3, Dlg4, Gphn, Gria1, Gria2, Homer1, Homer2, Nlgn1, Nlgn2, Nlgn3, Shank1, Shank3 |
| dendrites | Actb, Cyfip2, Ddn, Dlg4, Map1a, Map2 |
| axons | Ank3, Nav1, Sptnb4, Nfasc, Mapt, Tubb3 |

### Step D4 — Manual mapping dictionary

Build a **`mapping`** from subtype names to **lists of cluster id strings**, then apply it:

```python
def apply_manual_annotation(granule_adata, mapping, cluster_column="granule_subtype_kmeans"):
    k2sub = {}
    for subtype, clusters in mapping.items():
        for c in clusters:
            k2sub[c] = subtype
    granule_adata.obs["granule_subtype_manual"] = granule_adata.obs[cluster_column].astype(str).map(k2sub)
    granule_adata.obs["granule_subtype_manual_simple"] = granule_adata.obs["granule_subtype_manual"].apply(
        lambda s: "mixed" if pd.notna(s) and " & " in str(s) else str(s)
    )
    return granule_adata

# Main result (seed = 1)
mapping = {
    "pre-syn": ["0", "11", "12", "13"],
    "post-syn": ["1", "2", "3"],
    "dendrites": ["4", "8"],
    "axons": [],
    "pre & post": ["6"],
    "pre & den": [],
    "post & den": ["5", "9", "10"],
    "pre & post & den": ["7", "14"],
    "others": [],
}
granule_adata = apply_manual_annotation(granule_adata, mapping)
```

**Convention:** finer labels live in **`granule_subtype_manual`** (e.g. `"pre & post"`); **`granule_subtype_manual_simple`** collapses any label containing **`" & "`** to **`"mixed"`** and is used for density and summaries.

### Step D5 — Save labels

Save the `obs` columns `granule_id`, `sample`, `granule_subtype_kmeans`, `granule_subtype_manual`, and `granule_subtype_manual_simple` (e.g. to Parquet). [Step F](./07_neuropil_subdomains.md) needs `granule_subtype_kmeans` on the granule object.

**Next:** [Step E — WT vs AD density](./06_density_wt_ad.md)
