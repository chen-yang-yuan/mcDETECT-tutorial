# 4. Step C — Profile granules (`profile`)

[← Tutorial index](./README.md)

**Step C1.** Ensure the same **`mc`** instance still holds the **`transcripts`** used for detection.

**Step C2.** Choose the gene list **`genes`** (`3_detection.py` uses the full panel from `genes.csv`).

**Step C3.** Call:

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
| `granules` | `DataFrame` from `detect()` (or the merged rough table). |
| `genes` | Genes to count; **`None`** uses all genes present in `transcripts["target"]`. |
| `buffer` | Added to each sphere's radius when querying transcripts. |
| `print_itr`, `print_itr_interval` | Print progress every `print_itr_interval` granules. |

Each granule counts **all** transcripts of the selected genes within `sphere_r + buffer` of its (`sphere_x`, `sphere_y`, `layer_z`) center, not only marker transcripts.

**Output:** **`anndata.AnnData`**, with these fields:

- sparse **`X`**: raw counts, `n_granules × n_genes`;
- **`obs`**: granule metadata with `sphere_x` / `sphere_y` / `sphere_z` renamed to `global_x` / `global_y` / `global_z`, plus **`granule_id`** (`"gnl_0"`, `"gnl_1"`, …);
- **`var_names`**: `genes`.

**Step C4.** Keep raw counts and add a low-dimensional embedding for visualization (as in `3_detection.py`):

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

**Step C5 — Combine WT and AD (for Steps D–F).** For the WT vs AD comparison, profile each sample separately, then concatenate the raw profiles with `anndata.concat(..., label="batch")` and repeat Step C4 on the combined object (`4_post_detection.ipynb`). The combined object is the input to [Step D](./05_manual_subtyping.md).

**Next:** [Step D — Manual granule subtyping](./05_manual_subtyping.md)
