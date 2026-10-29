# 2. Step A — Construct `mcDETECT` and understand every parameter

[← Tutorial index](./README.md)

**Step A1.** Import the class:

```python
from mcDETECT.model import mcDETECT
```

**Step A2.** Read the parameters below. Each item is one argument of `mcDETECT(...)`, and the default value is shown in brackets. In this list, a "sphere" is the smallest sphere that contains all transcripts of one detected cluster; each sphere is a candidate granule.

1. **`type`** [required] — Platform type. Use `"discrete"` for MERSCOPE; see [Section 1](./01_what_mcdetect_expects.md).
2. **`transcripts`** [required] — The full transcript table; see [Section 1](./01_what_mcdetect_expects.md) for the required columns.
3. **`gnl_genes`** [required] — List of granule (synaptic) marker genes. DBSCAN clustering is run on the transcripts of these genes.
4. **`nc_genes`** [`None`] — List of negative-control genes. If **`None`**, `detect()` skips negative-control filtering. Otherwise, `detect()` runs the negative-control filter (`nc_filter`) as its last step.
5. **`eps`** [`1.5`] — DBSCAN search radius: the distance (in 3D) within which transcripts count as neighbors.
6. **`minspl`** [`None`] — Minimum number of neighboring transcripts DBSCAN needs to form a cluster (`min_samples`). If **`None`**, mcDETECT chooses this number separately for each gene, based on the gene's background density in the tissue. If you give an **integer**, that number is used for all genes; `3_detection.py` uses `minspl=3`.
7. **`grid_len`** [`1.0`] — Size of the grid squares used to estimate the tissue area when `min_samples` is chosen automatically. This is not the spot grid used in later analyses.
8. **`cutoff_prob`** [`0.95`] — Used only when `minspl` is `None`. The automatic `min_samples` is set to this quantile of the expected background (Poisson) count.
9. **`alpha`** [`5.0`] — Used only when `minspl` is `None`. Multiplies the expected background count within a circle of radius `eps` before the quantile is taken.
10. **`low_bound`** [`3`] — Smallest value allowed for the automatic `min_samples`. It is also the minimum number of transcripts at distinct positions a cluster must have to be kept.
11. **`size_thr`** [`4.0`] — Maximum sphere radius. Spheres with a radius of `size_thr` or more are removed. Use a very large value (e.g. `1e5`) to keep spheres of any size.
12. **`in_soma_thr`** [`0.1`] — Maximum in-soma ratio, i.e. the fraction of a sphere's transcripts that lie inside nuclei. Spheres at or above this value are removed. Use a value above 1 (e.g. `1.01`) to turn this filter off.
13. **`l`** [`1.0`] — Used when combining spheres found for **different** marker genes (`merge_sphere`). Let `d` be the distance between the two sphere centers and `r_a`, `r_b` their radii. The spheres are treated as overlapping if `d < l · (r_a + r_b)`. If one sphere lies inside the other (`d ≤ l · |r_a − r_b|`), only the larger sphere is kept.
14. **`rho`** [`0.2`] — For overlapping spheres where neither lies inside the other: if `d < rho · l · (r_a + r_b)`, the two spheres are merged into one new sphere. Otherwise, both are kept.
15. **`s`** [`1.0`] — Scaling factor for the radius of a sphere created by merging two spheres. The new sphere is the smallest sphere containing the marker transcripts of both.
16. **`nc_top`** [`20`] — Number of negative-control genes used in the filter: the **`nc_top`** genes with the most transcripts.
17. **`nc_thr`** [`0.1`] — A sphere passes the negative-control filter if it contains no negative-control transcripts, or if their number divided by the sphere's `size` is below `nc_thr`. Use **`None`** to keep all spheres while still adding the ratio as the `nc_ratio` column.
18. **`merge_genes`** [`False`] — If **`True`**, all marker genes are treated as one combined gene, and DBSCAN is run once on all marker transcripts together. Each sphere's `comp` then gives the number of different marker genes inside it. No combining of spheres across genes is needed in this case.
19. **`merged_gene_label`** [`"merged"`] — Name of the combined gene when `merge_genes=True`. It also appears in the `gene` column of the output.

**Step A3.** Create the `mcDETECT` object. These are the values used for the final (fine) detection in `3_detection.py`:

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

The marker genes used for MERSCOPE in `3_detection.py` are:

```python
syn_genes = ["Camk2a", "Cplx2", "Slc17a7", "Ddn", "Syp", "Map1a", "Shank1", "Syn1", "Gria1", "Gria2",
             "Cyfip2", "Vamp2", "Bsn", "Slc32a1", "Nfasc", "Syt1", "Tubb3", "Nav1", "Shank3", "Mapt"]
```

The **rough** and **fine** runs use the same parameters, except for `nc_genes`, `size_thr`, and `in_soma_thr` (see [Section 3](./03_granule_detection.md)).

**Next:** [Step B — Granule detection](./03_granule_detection.md)
