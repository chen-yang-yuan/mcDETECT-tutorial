# 4. Step C — Profile granules (`profile`)

[← Tutorial index](./README.md)

**Step C1.** Use the same **`mc`** object as in detection, so that it holds the same **`transcripts`** table.

**Step C2.** Choose the genes to count, **`genes`**. `3_detection.py` uses the full gene panel from `genes.csv`.

**Step C3.** Run:

```python
granule_adata = mc.profile(
    granules,
    genes=genes,
    buffer=0.0,
    print_itr=False,
    print_itr_interval=5000,
)
```

| Argument | Meaning |
|----------|---------|
| `granules` | The granule table from `detect()` (or the rough table from Step B2). |
| `genes` | Genes to count. If **`None`**, all genes in `transcripts["target"]` are counted. |
| `buffer` | Extra distance added to each granule's radius when counting transcripts. |
| `print_itr`, `print_itr_interval` | If `print_itr=True`, progress is printed every `print_itr_interval` granules. |

For each granule, `profile` counts **all** transcripts of the chosen genes within the granule's radius (plus `buffer`) of its center, not only the marker-gene transcripts. The center used is (`sphere_x`, `sphere_y`, `layer_z`).

**Output:** an **`anndata.AnnData`** object with:

- **`X`**: a sparse matrix of raw counts, with one row per granule and one column per gene;
- **`obs`**: the granule table, with `sphere_x` / `sphere_y` / `sphere_z` renamed to `global_x` / `global_y` / `global_z`, and a new **`granule_id`** column (`"gnl_0"`, `"gnl_1"`, …);
- **`var_names`**: the gene names.

**Step C4.** Save the raw counts in a layer, normalize, and compute PCA and t-SNE for visualization (as in `3_detection.py`):

```python
import scanpy as sc
from scipy.sparse import csr_matrix

granule_adata.layers["counts"] = csr_matrix(granule_adata.X.copy())
sc.pp.normalize_total(granule_adata, target_sum=1e4)
sc.pp.log1p(granule_adata)
sc.tl.pca(granule_adata, n_comps=10, svd_solver="auto")
sc.tl.tsne(granule_adata, n_pcs=10)
granule_adata.write_h5ad(output_path + "granule_adata_tsne.h5ad")
```

**Step C5 — Combine WT and AD (for Steps D–F).** To compare WT and AD, profile each sample separately and combine the raw count objects with `anndata.concat(..., label="batch")`. Then repeat Step C4 on the combined object (`4_post_detection.ipynb`). The combined object is the input to [Step D](./05_manual_subtyping.md).

**Next:** [Step D — Manual granule subtyping](./05_manual_subtyping.md)
