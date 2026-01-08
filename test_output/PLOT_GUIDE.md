# Example Quality Control Plots

This document describes the expected plots and how to interpret them.

## 1. Fragment Size Distribution

**File:** `fragment_size_distribution.pdf/png`

**Description:** Shows the distribution of DNA fragment sizes in your ATAC-seq library.

**Expected Pattern:**

![Fragment Size Distribution](fragment_size_pattern.png)

- **Peak at ~50-100 bp**: Nucleosome-free regions (NFR) - indicates successful ATAC-seq
- **Peak at ~200 bp**: Mononucleosomal fragments
- **Peaks at ~400, ~600 bp**: Di-, tri-nucleosomal fragments
- **Periodic pattern**: Clear nucleosomal ladder

**Quality Indicators:**

✅ **Good Quality:**
- Strong NFR peak (<100 bp)
- Clear nucleosomal peaks
- Smooth, periodic distribution

❌ **Poor Quality:**
- Flat distribution (degraded DNA)
- Single broad peak (failed ATAC)
- Very high peaks >1000 bp (genomic DNA contamination)

**Example Interpretation:**

```
Sample1: Strong NFR peak at 80bp, clear nucleosome ladder → Excellent
Sample2: Weak NFR peak, high background → Poor library quality
Sample3: No peaks, flat distribution → Failed experiment
```

---

## 2. TSS Enrichment Profile

**File:** `TSS_enrichment_profile.pdf/png`

**Description:** Shows ATAC-seq signal enrichment around transcription start sites (TSS).

**Expected Pattern:**

- Sharp peak centered at TSS position (0)
- Enrichment score >7 for good quality
- Symmetrical distribution

**Quality Indicators:**

✅ **Excellent (score >10):**
```
     |
   * | *
  *  |  *
 *   |   *
*____|____*
   TSS
```

⚠️ **Acceptable (score 5-7):**
```
   . | .
  .  |  .
 .   |   .
.____|____.
   TSS
```

❌ **Poor (score <5):**
```
____________
     |
   TSS
```

**Interpretation:**

High TSS enrichment indicates:
- Good chromatin accessibility at promoters
- Successful targeting of open chromatin
- High library complexity

---

## 3. Sample Correlation Heatmap

**File:** `correlation_heatmap.pdf/png`

**Description:** Pearson correlation of read coverage between samples.

**Expected Pattern:**

```
        S1   S2   S3
    S1 [1.0  0.95 0.94]
    S2 [0.95 1.0  0.96]
    S3 [0.94 0.96 1.0 ]
```

**Quality Indicators:**

✅ **Excellent:**
- Biological replicates: r > 0.90
- Technical replicates: r > 0.95
- Diagonal = 1.0 (self-correlation)

⚠️ **Acceptable:**
- Biological replicates: r > 0.80

❌ **Poor:**
- Replicates: r < 0.80 (sample quality issues or batch effects)

**Color Scale:**

- Dark red/blue: High correlation (>0.9)
- Light colors: Moderate correlation (0.7-0.9)
- White/yellow: Low correlation (<0.7)

---

## 4. PCA Plot

**File:** `PCA_plot.pdf/png`

**Description:** Principal Component Analysis showing sample clustering.

**Expected Pattern:**

- Biological replicates cluster together
- Different conditions separate on PC1 or PC2
- PC1 explains most variance (40-60%)

**Interpretation:**

```
PC2 ^
    |  Condition A (●●●)
    |        
    |________________> PC1
    |        
    |  Condition B (○○○)
```

✅ **Good:**
- Replicates cluster tightly
- Conditions separate clearly
- PC1 > 40% variance

❌ **Issues:**
- Replicates scatter widely (technical variation)
- Unexpected clustering (batch effects)
- One sample outlier (quality issue)

---

## 5. Coverage Plot

**File:** `coverage_plot.pdf/png`

**Description:** Cumulative coverage distribution across the genome.

**Expected Pattern:**

- Smooth curve rising from left to right
- All samples show similar patterns
- Plateau indicates saturation

**Quality Indicators:**

✅ **Good:**
- Consistent coverage across samples
- Smooth curves without sudden jumps
- Similar coverage levels

❌ **Poor:**
- Highly variable between replicates
- Very low coverage (<30%)
- Erratic curves (mapping issues)

---

## 6. Peak Distribution Bar Plot

**File:** `peak_distribution_barplot.pdf/png`

**Description:** Distribution of peaks across genomic features.

**Expected Distribution (typical ATAC-seq):**

```
Promoter (TSS)    ████████████████ 30-40%
Intron            ████████████ 20-30%
Intergenic        ████████ 15-20%
Exon              ████ 8-12%
TTS               ███ 5-10%
UTR               ██ 5-8%
```

**Interpretation:**

- **High promoter enrichment (>30%)**: Expected for ATAC-seq
- **Low promoter (<20%)**: Possible library quality issues
- **High intergenic (>40%)**: Enhancer-rich cell type or quality issues
- **Very high exon (>20%)**: Unusual, check protocol

**Cell-Type Variations:**

- **Stem cells**: Higher intergenic (active enhancers)
- **Differentiated cells**: Higher promoter
- **Cancer cells**: More heterogeneous distribution

---

## 7. QC Metrics Plots

### a. Mapping Rate

**File:** `mapping_rate.pdf/png`

**Expected:** >90% for all samples

```
100% |████████████████████| Sample1 (95.5%)
     |███████████████████ | Sample2 (95.4%)
     |████████████████████| Sample3 (95.4%)
  0% |____________________|
```

### b. Duplication Rate

**File:** `duplication_rate.pdf/png`

**Expected:** <40%, ideally <30%

```
50% |                    |
    |███████             | Sample1 (26.7%)
    |███████             | Sample2 (26.9%)
    |███████             | Sample3 (26.6%)
 0% |____________________|
```

### c. Read Counts Progression

**File:** `read_counts_progression.pdf/png`

**Shows:** Raw → Trimmed → Final reads

```
60M |████████████████████| Raw
    |███████████████████ | Trimmed
    |███████████████     | Final (dedup)
 0M |____________________|
```

**Typical losses:**
- Trimming: 2-5% loss
- Mapping: 3-10% loss
- Deduplication: 20-40% loss

---

## How to Use These Plots

### 1. Quick Quality Check

Check these files first:
1. `multiqc_report.html` - Overall summary
2. `fragment_size_distribution.pdf` - Library quality
3. `TSS_enrichment_profile.pdf` - Targeting success
4. `pipeline_summary_stats.tsv` - Numeric metrics

### 2. Troubleshooting

If metrics are poor:
1. Check `fragment_size_distribution.pdf` for library issues
2. Check `TSS_enrichment_profile.pdf` for targeting
3. Check `correlation_heatmap.pdf` for sample consistency
4. Review FastQC reports in `QC/` directory

### 3. Reporting

For publications, include:
- Fragment size distribution
- TSS enrichment
- Sample correlation
- Summary statistics table
- Peak distribution

---

## Expected Values Summary

| Plot | Metric | Excellent | Good | Poor |
|------|--------|-----------|------|------|
| Fragment Size | NFR peak | 50-100bp | Present | Absent |
| TSS Enrichment | Score | >10 | 7-10 | <5 |
| Correlation | Replicate r | >0.95 | 0.85-0.95 | <0.85 |
| Peak Distribution | Promoter % | 30-40% | 20-30% | <20% |
| Mapping Rate | % mapped | >95% | 85-95% | <85% |
| Duplication | % dup | <20% | 20-35% | >40% |
| FRiP | Score | >0.4 | 0.3-0.4 | <0.3 |

---

## Comparing to Test Output

Your plots should resemble those in `test_output/example_plots/`:

```bash
# Visual comparison
ls -1 plots/*.pdf
ls -1 test_output/example_plots/*.pdf

# Check if metrics are similar
cat final_results/pipeline_summary_stats.tsv
cat test_output/example_summary_stats.tsv
```

If significantly different, see [TROUBLESHOOTING.md](../TROUBLESHOOTING.md).
