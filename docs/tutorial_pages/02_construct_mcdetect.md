# 2. Step A — Construct `mcDETECT` and understand every parameter

[← Tutorial index](./README.md)

**Step A1.** Import the class:

```python
from mcDETECT.model import mcDETECT
```

**Step A2.** Read the parameter list below in order. Each entry matches one argument of `mcDETECT(...)`; package defaults are given in brackets.

1. **`type`** [required] — `"discrete"` for MERSCOPE; see [Section 1](./01_what_mcdetect_expects.md).
2. **`transcripts`** [required] — Full transcript `DataFrame`; column requirements are in [Section 1](./01_what_mcdetect_expects.md).
3. **`gnl_genes`** [required] — `list[str]`: all granule / synaptic marker genes to run DBSCAN on.
4. **`nc_genes`** [`None`] — `list[str]` or **`None`**. If **`None`**, `detect()` skips negative-control filtering. Otherwise `nc_filter` runs at the end of `detect()`.
5. **`eps`** [`1.5`] — DBSCAN neighborhood radius in coordinate units (3D).
6. **`minspl`** [`None`] — If **`None`**, `poisson_select(gene)` sets per-gene `min_samples` from tissue area and background density. If an **integer**, that value is used for all genes (as in `3_detection.py` with `minspl=3`).
7. **`grid_len`** [`1.0`] — Bin width when estimating tissue area for the Poisson model (not the spot grid in downstream notebooks).
8. **`cutoff_prob`** [`0.95`] — Quantile of the Poisson background used as `min_samples` (only when `minspl is None`).
9. **`alpha`** [`5.0`] — Multiplier on the expected background count inside `π eps²` when selecting `min_samples` (only when `minspl is None`).
10. **`low_bound`** [`3`] — Lower floor for automatic `min_samples`, and the minimum number of **unique** transcript positions a DBSCAN cluster needs before it is turned into a sphere.
11. **`size_thr`** [`4.0`] — Keep only spheres whose minimum enclosing ball has **radius < `size_thr`**. Use a very large value (e.g. `1e5`) for a “no radius cap” exploratory run.
12. **`in_soma_thr`** [`0.1`] — Keep only spheres with **in-soma ratio < `in_soma_thr`**. Use a value above 1 (e.g. `1.01`) to disable.
13. **`l`** [`1.0`] — Scales distances when comparing spheres from **different** genes in `merge_sphere`. Two spheres are treated as overlapping when the center distance `d < l · (r_a + r_b)`. If one is nested in the other (`d ≤ l · |r_a − r_b|`), only the larger sphere is kept.
14. **`rho`** [`0.2`] — For overlapping, non-nested spheres: if `d < rho · l · (r_a + r_b)` the two are merged into one new sphere; otherwise both are kept.
15. **`s`** [`1.0`] — Scales the radius of a **new** sphere created by a merge (minimum enclosing ball over the marker transcripts of both spheres).
16. **`nc_top`** [`20`] — When `nc_genes` is set, only the top **`nc_top`** negative-control genes by transcript count enter the NC filter.
17. **`nc_thr`** [`0.1`] — A sphere passes the NC filter if it contains no NC transcripts or if (NC transcripts) / (sphere `size`) **< `nc_thr`**. Use **`None`** to keep all spheres but still add the `nc_ratio` column.
18. **`merge_genes`** [`False`] — If **`True`**, all granule markers are pooled into a single pseudo-marker and DBSCAN runs once on the pooled transcripts. Each sphere's `comp` then counts the distinct original marker genes inside it, and the cross-gene merge step has nothing to merge.
19. **`merged_gene_label`** [`"merged"`] — Label used for that pseudo-marker (and in the `gene` column of the output) when `merge_genes=True`.

**Step A3.** Instantiate. These are the values used for fine detection in `3_detection.py`:

```python
mc = mcDETECT(
    type="discrete",
    transcripts=transcripts,
    gnl_genes=syn_genes,
    nc_genes=nc_genes,
    eps=1.5,
    minspl=3,
    grid_len=1,
    cutoff_prob=0.95,
    alpha=10,
    low_bound=3,
    size_thr=4.0,
    in_soma_thr=0.1,
    l=1,
    rho=0.2,
    s=1,
    nc_top=20,
    nc_thr=0.1,
    merge_genes=False,
    merged_gene_label="merged",
)
```

The marker list used for MERSCOPE in `3_detection.py` is:

```python
syn_genes = ["Camk2a", "Cplx2", "Slc17a7", "Ddn", "Syp", "Map1a", "Shank1", "Syn1", "Gria1", "Gria2",
             "Cyfip2", "Vamp2", "Bsn", "Slc32a1", "Nfasc", "Syt1", "Tubb3", "Nav1", "Shank3", "Mapt"]
```

The same hyperparameter names apply to **rough** and **fine** runs; only `nc_genes`, `size_thr`, and `in_soma_thr` change (see [Section 3](./03_granule_detection.md)).

**Next:** [Step B — Granule detection](./03_granule_detection.md)
