# Test Output Examples

This directory contains example outputs from a successful ATAC-seq pipeline run on GM12878 cells (human lymphoblastoid cell line).

## Files Included

### Summary Statistics
- `example_summary_stats.tsv` - Pipeline summary table showing QC metrics for all samples
- `example_frip_scores.txt` - Fraction of Reads in Peaks (FRiP) scores
- `example_peak_distribution.txt` - Genomic distribution of peaks

### Expected Results for GM12878 ATAC-seq

| Metric | Sample 1 | Sample 2 | Sample 3 | Expected Range |
|--------|----------|----------|----------|----------------|
| Raw Reads | 52.8M | 48.9M | 51.3M | 20-100M |
| Mapping Rate | 95.5% | 95.4% | 95.4% | >90% |
| Duplication Rate | 26.7% | 26.9% | 26.6% | <40% |
| FRiP Score | 0.387 | 0.402 | 0.378 | >0.3 |
| Total Peaks | 47,823 | - | - | 30K-80K |

### Quality Interpretation

**Excellent Quality Indicators:**
- ✅ High mapping rate (>95%)
- ✅ Low-moderate duplication rate (~27%)
- ✅ High FRiP scores (>0.35)
- ✅ Consistent metrics across replicates
- ✅ Expected number of peaks (~48K)

**Peak Distribution:**
- 31.8% at promoters (TSS regions) - indicates strong chromatin accessibility at active genes
- 20.5% in introns - expected for accessible chromatin
- 14.1% intergenic - includes enhancers and regulatory elements
- Good distribution across genomic features

## How to Use These Examples

### Compare Your Results

After running the pipeline, compare your summary statistics to these examples:

```bash
# View your results
cat final_results/pipeline_summary_stats.tsv

# Compare to example
diff final_results/pipeline_summary_stats.tsv test_output/example_summary_stats.tsv
```

### Check Quality Metrics

Your samples should have similar metrics:
- Mapping rate within ±5% of examples
- FRiP score within ±0.1 of examples
- Duplication rate <40%
- Peak count in similar range (±20,000)

### Troubleshooting

If your results differ significantly:
- **Lower mapping rate (<85%)**: Check genome reference, possible contamination
- **Lower FRiP (<0.2)**: Poor library quality, failed ATAC-seq
- **Higher duplication (>40%)**: Over-amplification, low complexity library
- **Fewer peaks (<20K)**: Low sequencing depth, poor accessibility

See [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) for detailed solutions.

## Example Plots

Example plots are shown in the main [USAGE.md](../USAGE.md) documentation:
- Fragment size distribution
- TSS enrichment
- Sample correlation heatmap
- PCA plots
- Coverage plots

## Data Source

These example data represent typical high-quality ATAC-seq results from:
- **Cell Type**: GM12878 (human lymphoblastoid cells)
- **Sequencing**: Paired-end 2x50bp
- **Platform**: Illumina NovaSeq
- **Depth**: ~50 million reads per sample
- **Replicates**: 3 biological replicates

## Citation

If using these examples in publications or presentations, cite the original ATAC-seq method:

Buenrostro, J.D., et al. (2013). Transposition of native chromatin for fast and sensitive epigenomic profiling of open chromatin, DNA-binding proteins and nucleosome position. *Nature Methods*, 10(12), 1213-1218.

---

**Note**: These are example/reference data. Your actual results will vary based on cell type, library quality, and sequencing depth.
