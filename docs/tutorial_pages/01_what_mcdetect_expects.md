# 1. What mcDETECT expects

[← Tutorial index](./README.md)

### 1.1 Installation

The tutorial matches **mcDETECT v2.1.6**. Either install the package alone:

```bash
pip3 install mcDETECT
```

or, to also run the repository's analysis scripts, create the tested Conda environment from the **[mcDETECT](https://github.com/chen-yang-yuan/mcDETECT)** repository:

```bash
git clone https://github.com/chen-yang-yuan/mcDETECT
cd mcDETECT/code/utils
conda env create -f env.yaml
conda activate mcDETECT-env
```

The package has three modules: **`mcDETECT.model`** (the `mcDETECT` class: detection and profiling), **`mcDETECT.downstream`** (subtyping and spatial embedding helpers such as `spot_embedding`), and **`mcDETECT.utils`**.

### 1.2 Platform type

| Value | Use case |
|--------|----------|
| `"discrete"` | Z is a small set of optical planes, as in MERSCOPE. The sorted unique `global_z` values define the internal z-grid, and each sphere records its nearest plane as **`layer_z`**. |
| `"continuous"` | Z is continuous; `layer_z` equals the sphere's own z-coordinate. |

**MERSCOPE:** use `"discrete"`, as throughout this tutorial.

### 1.3 Transcript table (`pandas.DataFrame`)

Each row is one transcript. The detector relies on:

| Column | Role |
|--------|------|
| `global_x`, `global_y`, `global_z` | Spatial coordinates in µm (same units as `eps`, `grid_len`, sphere radii). In the MERSCOPE analysis, the z-plane index is multiplied by 1.5 to give µm. |
| `target` | Gene name string (MERSCOPE's `gene` column, renamed); granule markers must appear here and in `gnl_genes`. |
| `overlaps_nucleus` | Boolean or 0/1; used to compute the **in-soma ratio** of each sphere. In the MERSCOPE analysis, it flags transcripts that fall on dilated DAPI nuclear masks (`1_clean_transcripts.ipynb`). |
| `cell_id` | Optional; required only if you pass `record_cell_id=True` to `dbscan` / `detect`, in which case each sphere gets the modal `cell_id` of its transcripts. |

Negative controls are passed as **`nc_genes`** and matched via `target` when filtering is enabled.

With `merge_genes=True`, the constructor adds two columns to **`transcripts` in place**: `target_original` (copy of `target`) and `target_detect` (granule markers replaced by `merged_gene_label`). `target` itself is left unchanged.

### 1.4 Files used in the MERSCOPE workflow

The mcDETECT repository's MERSCOPE scripts read, per sample, from `data/<dataset>/processed_data/`:

| File | Content |
|------|---------|
| `transcripts.parquet` | Transcript table above. |
| `genes.csv` | Gene panel (first column) used for profiling. |
| `negative_controls.csv` | Negative-control genes (column `Gene`). |
| `spots.h5ad` | 50 µm spot grid with `global_x`, `global_y`, `brain_area`. |
| `adata.h5ad` | Cell-level data with `cell_type` (e.g. `Glutamatergic`, `GABAergic`). |

**Next:** [Step A — Construct `mcDETECT`](./02_construct_mcdetect.md)
