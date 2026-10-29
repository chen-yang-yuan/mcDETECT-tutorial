# 1. What mcDETECT expects

[← Tutorial index](./README.md)

### 1.1 Installation

This tutorial uses **mcDETECT v2.1.6**. To install only the package:

```bash
pip3 install mcDETECT
```

To also run the analysis scripts in the **[mcDETECT](https://github.com/chen-yang-yuan/mcDETECT)** repository, create the tested Conda environment instead:

```bash
git clone https://github.com/chen-yang-yuan/mcDETECT
cd mcDETECT/code/utils
conda env create -f env.yaml
conda activate mcDETECT-env
```

The package has three modules:

- **`mcDETECT.model`** contains the `mcDETECT` class, used for granule detection and profiling.
- **`mcDETECT.downstream`** contains functions for later analyses, such as `spot_embedding`.
- **`mcDETECT.utils`** contains general helper functions.

### 1.2 Platform type

| Value | Use case |
|--------|----------|
| `"discrete"` | Transcripts are measured on a few fixed z-planes, as in MERSCOPE. mcDETECT reads the z-planes from the unique `global_z` values. For each granule, it records the closest z-plane as **`layer_z`**. |
| `"continuous"` | The z-coordinate can take any value. `layer_z` is then the same as the granule's z-coordinate. |

**MERSCOPE:** use `"discrete"`. This tutorial uses it throughout.

### 1.3 Transcript table (`pandas.DataFrame`)

Each row is one transcript. mcDETECT uses these columns:

| Column | Role |
|--------|------|
| `global_x`, `global_y`, `global_z` | Transcript coordinates in µm. `eps`, `grid_len`, and the granule radii use the same unit. In the MERSCOPE analysis, the z-plane number is multiplied by 1.5 to convert it to µm. |
| `target` | Gene name. In MERSCOPE output, this column is called `gene` and is renamed to `target`. Every granule marker must appear here and in `gnl_genes`. |
| `overlaps_nucleus` | 1 if the transcript lies inside a nucleus, 0 otherwise (True/False also works). It is used to compute each granule's **in-soma ratio**. In the MERSCOPE analysis, nuclei are taken from the DAPI images and slightly enlarged (`1_clean_transcripts.ipynb`). |
| `cell_id` | Optional. Needed only if you set `record_cell_id=True` in `dbscan` or `detect`. Each granule is then given the `cell_id` that occurs most often among its transcripts. |

Negative-control genes are given separately in **`nc_genes`** and are matched against the `target` column.

If you set `merge_genes=True`, mcDETECT adds two columns to your **`transcripts`** table. `target_original` is a copy of `target`. `target_detect` is the same as `target`, except that every granule marker is replaced by `merged_gene_label`. The `target` column itself is not changed.

### 1.4 Files used in the MERSCOPE workflow

For each sample, the MERSCOPE scripts in the mcDETECT repository read these files from `data/<dataset>/processed_data/`:

| File | Content |
|------|---------|
| `transcripts.parquet` | The transcript table described above. |
| `genes.csv` | The gene panel (first column), used for profiling. |
| `negative_controls.csv` | Negative-control genes (column `Gene`). |
| `spots.h5ad` | A grid of 50 × 50 µm spots with `global_x`, `global_y`, and `brain_area`. |
| `adata.h5ad` | Cell-level data with `cell_type` (e.g. `Glutamatergic`, `GABAergic`). |

**Next:** [Step A — Construct `mcDETECT`](./02_construct_mcdetect.md)
