# Generating Publication-Ready Example Plots

This directory contains example plots for the ATAC-seq pipeline documentation.

## Quick Start

### Generate All Plots

```bash
cd test_output/example_plots/
python generate_plots.py
```

This will create:
- `fragment_size_distribution.png/pdf`
- `TSS_enrichment_profile.png/pdf`
- `correlation_heatmap.png/pdf`
- `peak_distribution_barplot.png/pdf`
- `qc_metrics_summary.png/pdf`
- `read_counts_progression.png/pdf`

## Requirements

```bash
pip install matplotlib numpy pandas seaborn
```

Or use conda:
```bash
conda install matplotlib numpy pandas seaborn
```

## Plot Descriptions

### 1. Fragment Size Distribution
Shows the nucleosome-free and nucleosomal fragment patterns typical of high-quality ATAC-seq data.

**Features:**
- NFR peak at ~80 bp
- Mononucleosome at ~200 bp
- Di/tri-nucleosome peaks
- Three biological replicates

### 2. TSS Enrichment Profile
Demonstrates strong enrichment of ATAC-seq signal at transcription start sites.

**Features:**
- Enrichment score: 8.5
- Sharp, centered peak
- ±3kb window around TSS
- Consistent across replicates

### 3. Correlation Heatmap
Shows high reproducibility between biological replicates.

**Features:**
- Pearson correlation >0.95
- Color-coded heatmap
- Correlation values displayed

### 4. Peak Distribution
Genomic distribution of accessible chromatin regions.

**Features:**
- Bar plot with counts
- Pie chart with percentages
- 7 genomic feature categories

### 5. QC Metrics Summary
Three-panel overview of key quality metrics.

**Features:**
- Mapping rate (>95%)
- Duplication rate (<30%)
- FRiP scores (>0.35)
- Quality thresholds marked

### 6. Read Counts Progression
Shows read filtering through the pipeline.

**Features:**
- Raw → Trimmed → Mapped → Final
- Four processing stages
- Grouped bar chart

## Customization

Edit `generate_plots.py` to:
- Change colors: Modify color palette
- Adjust dimensions: Change `figsize` parameters
- Add more samples: Extend data arrays
- Modify thresholds: Update reference lines

## Using in Documentation

### In README.md

```markdown
![Fragment Size](test_output/example_plots/fragment_size_distribution.png)
```

### Side-by-side images

```markdown
<p align="center">
  <img src="test_output/example_plots/fragment_size_distribution.png" width="45%">
  <img src="test_output/example_plots/TSS_enrichment_profile.png" width="45%">
</p>
```

### In presentations

Use the PDF versions for high-quality slides:
```bash
ls *.pdf
```

## File Formats

Each plot is generated in two formats:
- **PNG**: For web/GitHub (300 DPI)
- **PDF**: For publications/presentations (vector graphics)

## Plot Standards

All plots follow publication standards:
- **Resolution**: 300 DPI minimum
- **Font**: Arial/DejaVu Sans
- **Size**: Appropriate for journals (single/double column)
- **Colors**: Color-blind friendly palettes
- **Labels**: Clear axis labels and titles
- **Grid**: Subtle gridlines for readability

## Regenerating After Changes

If you modify the script:

```bash
# Delete old plots
rm *.png *.pdf

# Regenerate
python generate_plots.py

# Verify outputs
ls -lh *.png *.pdf
```

## Integration with Pipeline

These example plots show what users should expect from the pipeline. When the actual pipeline runs, it generates similar plots with real data:

**Pipeline output:** `plots/`
**Example output:** `test_output/example_plots/`

Users can compare their results to these examples for quality assessment.

## Citation

If using these plots in presentations or papers, cite:
- The ATAC-seq pipeline (see main README.md)
- The example data source (GM12878 cells)

---

**Generated with:** Python 3.9+, Matplotlib 3.5+, NumPy, Pandas, Seaborn
