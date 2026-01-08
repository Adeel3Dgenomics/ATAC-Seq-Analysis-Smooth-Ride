# ATAC-seq Pipeline - Complete Project Structure

```
ATAC-seq-pipeline/
│
├── README.md                          # Main documentation (start here!)
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore rules
├── CHANGELOG.md                       # Version history
├── CITATIONS.md                       # How to cite tools
├── CONTRIBUTING.md                    # Contribution guidelines
│
├── INSTALL.md                         # Installation instructions
├── USAGE.md                           # Detailed usage guide
├── TROUBLESHOOTING.md                 # Common problems & solutions
│
├── environment.yml                    # Conda environment file
├── requirements.txt                   # Software requirements list
├── Dockerfile                         # Docker container definition
├── config.example.sh                  # Configuration template
│
├── ATAC_main.sh                       # ⭐ Main pipeline script
├── submit_ATAC.sh                     # SLURM submission script
│
├── scripts/                           # Helper scripts
│   ├── check_dependencies.sh          # Verify installations
│   ├── install_dependencies.sh        # Automated installer
│   └── README.md                      # Scripts documentation
│
├── test_output/                       # Example outputs for comparison
│   ├── README.md                      # How to use test outputs
│   ├── PLOT_GUIDE.md                  # Plot interpretation guide
│   ├── example_summary_stats.tsv      # Example metrics table
│   ├── example_frip_scores.txt        # Example FRiP scores
│   ├── example_peak_distribution.txt  # Example peak distribution
│   └── example_plots/                 # Example plot images
│       ├── fragment_size_dist.png
│       ├── TSS_enrichment.png
│       ├── correlation_heatmap.png
│       └── ... (more example plots)
│
└── docs/                              # Additional documentation
    ├── QUICK_START.md                 # Quick start guide
    ├── FAQ.md                         # Frequently asked questions
    ├── BEST_PRACTICES.md              # Analysis best practices
    └── ADVANCED_USAGE.md              # Advanced features
```

## Core Files Description

### Main Pipeline Files

- **ATAC_main.sh**: The main pipeline script that orchestrates all analysis steps
- **submit_ATAC.sh**: SLURM cluster submission script
- **config.example.sh**: Configuration template (copy to config.sh and edit)

### Documentation Files

- **README.md**: Overview, features, quick start, and general information
- **INSTALL.md**: Step-by-step installation for conda, manual, and Docker
- **USAGE.md**: Comprehensive usage guide with examples and interpretations
- **TROUBLESHOOTING.md**: Solutions to common problems
- **CHANGELOG.md**: Version history and updates
- **CITATIONS.md**: How to cite all tools used
- **CONTRIBUTING.md**: Guidelines for contributors

### Configuration Files

- **environment.yml**: Conda environment specification
- **requirements.txt**: List of all required software
- **config.example.sh**: Template for pipeline configuration
- **Dockerfile**: Docker container definition

### Scripts Directory

- **check_dependencies.sh**: Verifies all required software is installed
- **install_dependencies.sh**: Automated installation via conda

### Test Output Directory

Contains example results from GM12878 cells for quality comparison:
- Summary statistics tables
- FRiP scores
- Peak distribution
- Example plots
- Interpretation guides

## Output Directory Structure

After running the pipeline, your analysis directory will contain:

```
your_analysis_directory/
│
├── .pipeline_progress              # Checkpoint file for resume
├── command_log.txt                 # All executed commands
├── reproducibility_log.txt         # Software versions & parameters
│
├── QC/                             # Quality control reports
│   ├── raw/                        # FastQC on raw data
│   │   ├── *_fastqc.html
│   │   └── *_fastqc.zip
│   └── trimmed/                    # FastQC on trimmed data
│       ├── *_fastqc.html
│       └── *_fastqc.zip
│
├── trimmed_data/                   # Adapter-trimmed FASTQ files
│   ├── *_val_1.fq.gz
│   └── *_val_2.fq.gz
│
├── alignment/                      # Aligned reads
│   ├── *.sorted.bam
│   ├── *.sorted.bam.bai
│   └── dedup/                      # Deduplicated BAM files
│       ├── *.dedup.bam
│       ├── *.dedup.bam.bai
│       ├── *.qnamesort.bam
│       └── *_dup_metrics.txt
│
├── peaks/                          # Called peaks
│   └── ATAC_peaks.narrowPeak
│
├── blacklist_removed/              # Filtered peaks
│   └── ATAC_peaks.filtered.narrowPeak    # ⭐ FINAL PEAKS
│
├── bigwig_tracks/                  # Genome browser tracks
│   └── *.bw                        # Load these in IGV/UCSC
│
├── final_results/                  # ⭐ MAIN RESULTS
│   ├── pipeline_summary_stats.tsv  # ⭐ KEY FILE - QC metrics
│   ├── ATAC_annotated_homer.txt    # Peak annotations
│   ├── ATAC_peaks_genes_overlap.txt
│   ├── ATAC_peaks_closest_genes.txt
│   ├── peak_distribution_summary.txt
│   ├── counts.txt                  # For differential analysis
│   └── frip/
│       └── frip_scores.txt         # FRiP quality scores
│
├── plots/                          # ⭐ VISUALIZATIONS
│   ├── fragment_size_distribution.pdf
│   ├── TSS_enrichment_profile.pdf
│   ├── TSS_heatmap.pdf
│   ├── correlation_heatmap.pdf
│   ├── PCA_plot.pdf
│   ├── coverage_plot.pdf
│   ├── peak_distribution_barplot.pdf
│   ├── peak_distribution_piechart.pdf
│   ├── mapping_rate.pdf
│   ├── duplication_rate.pdf
│   ├── read_counts_progression.pdf
│   └── ... (PNG versions also created)
│
└── multiqc_report/                 # ⭐ INTEGRATED QC REPORT
    └── multiqc_report.html         # Open this in browser first!
```

## Getting Started Workflow

### 1. Installation
```bash
# Clone repository
git clone https://github.com/yourusername/ATAC-seq-pipeline.git
cd ATAC-seq-pipeline

# Install dependencies
bash scripts/install_dependencies.sh
# OR
conda env create -f environment.yml
conda activate atac-seq

# Verify installation
bash scripts/check_dependencies.sh
```

### 2. Download Reference Genome
```bash
# See INSTALL.md for detailed instructions
mkdir -p ~/refs/hg19
cd ~/refs/hg19
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
gunzip hg19.fa.gz
bowtie2-build hg19.fa bowtie2_index/hg19
```

### 3. Configure Pipeline
```bash
# Copy configuration template
cp config.example.sh config.sh

# Edit with your paths
nano config.sh
# Set BASE_DIR, RAW_DIR, GENOME_INDEX, etc.
```

### 4. Run Pipeline
```bash
# Activate environment
conda activate atac-seq

# Run pipeline
bash ATAC_main.sh

# OR submit to SLURM cluster
sbatch submit_ATAC.sh
```

### 5. Check Results
```bash
# View MultiQC report
firefox multiqc_report/multiqc_report.html

# Check summary statistics
cat final_results/pipeline_summary_stats.tsv

# View plots
ls plots/*.pdf

# Compare to test outputs
diff final_results/pipeline_summary_stats.tsv test_output/example_summary_stats.tsv
```

## Key Files to Check After Running

1. **multiqc_report/multiqc_report.html** - Overall QC summary
2. **final_results/pipeline_summary_stats.tsv** - Metrics table
3. **plots/fragment_size_distribution.pdf** - Library quality
4. **plots/TSS_enrichment_profile.pdf** - Targeting success
5. **blacklist_removed/ATAC_peaks.filtered.narrowPeak** - Final peaks
6. **bigwig_tracks/*.bw** - For genome browser visualization

## Important Notes

### Files You Should Edit
- ✅ `config.sh` - Your analysis configuration (copy from config.example.sh)

### Files You Should NOT Edit
- ❌ `ATAC_main.sh` - Main pipeline (unless contributing changes)
- ❌ `config.example.sh` - Template (keep as reference)
- ❌ `environment.yml` - Dependency specifications

### Hidden Files
- `.pipeline_progress` - Enables resume capability
- `.gitignore` - Prevents committing large data files

### Large Files (Not in Git)
- Raw FASTQ files (your data)
- BAM files (generated)
- BigWig files (generated)
- Peak files (generated)

## Quick Reference

### Most Important Commands
```bash
# Check installation
bash scripts/check_dependencies.sh

# Configure
cp config.example.sh config.sh && nano config.sh

# Run
bash ATAC_main.sh

# Resume if interrupted
bash ATAC_main.sh  # Automatically resumes

# Start fresh
rm .pipeline_progress && bash ATAC_main.sh

# Check progress
cat .pipeline_progress
```

### Most Important Files to Read
1. README.md - Start here
2. INSTALL.md - Setup guide
3. USAGE.md - How to run
4. test_output/README.md - Compare your results
5. TROUBLESHOOTING.md - If issues arise

## Questions?

- 📖 **Documentation**: Read the docs in order: README → INSTALL → USAGE
- 🐛 **Bug Reports**: GitHub Issues
- 💬 **Questions**: GitHub Discussions  
- 📧 **Email**: m.muzammal.adeel@outlook.com

## Repository Maintenance

### Before Committing
```bash
# Check what will be committed
git status

# Don't commit large data files
git add *.sh *.md *.yml  # Add specific files only

# Good commit message
git commit -m "Add feature: brief description"
```

### Updating Your Fork
```bash
git fetch upstream
git merge upstream/main
git push origin main
```

---

**Project Status**: Production Ready v1.0.0

**Last Updated**: January 8, 2026

**License**: MIT
