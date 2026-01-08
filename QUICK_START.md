# Quick Start Guide

**Never done bioinformatics before? Start here!**

This guide assumes **zero background** in bioinformatics and will walk you through every step.

## What is ATAC-seq?

ATAC-seq (Assay for Transposase-Accessible Chromatin using sequencing) identifies which parts of your DNA are "open" and accessible in your cells. Think of it like finding which books on a library shelf are easy to reach (open chromatin) vs. which are packed away (closed chromatin).

## What This Pipeline Does

Transforms raw sequencing data → publication-ready results

```
Raw Data (.fastq.gz)
    ↓
Quality Check
    ↓
Trim Adapters
    ↓
Align to Genome
    ↓
Find Accessible Regions (Peaks)
    ↓
Annotate & Visualize
    ↓
Publication Figures & Tables ✓
```

## Before You Start

### What You Need

1. **A computer with:**
   - Linux or macOS (or Windows with WSL2)
   - 32+ GB RAM
   - 500+ GB free disk space
   - Internet connection

2. **Your sequencing data:**
   - Paired-end FASTQ files (`.fastq.gz`)
   - Usually from your sequencing core facility

3. **About 2-4 hours** for setup (one-time)

### What You'll Get

- Quality control reports
- List of accessible chromatin regions (peaks)
- Genome browser tracks
- Publication-ready figures
- Statistical summaries

## Step-by-Step Instructions

### Step 1: Install the Pipeline (One-Time Setup)

#### 1a. Open Terminal

**Linux/Mac:**
- Press `Ctrl+Alt+T` (Linux) or `Cmd+Space`, type "Terminal" (Mac)

**Windows:**
- Install WSL2 first: [Windows Guide](https://docs.microsoft.com/en-us/windows/wsl/install)

#### 1b. Download Pipeline

```bash
# Copy and paste these commands one at a time
cd ~
git clone https://github.com/yourusername/ATAC-seq-pipeline.git
cd ATAC-seq-pipeline
```

**What this does:** Downloads the pipeline software to your computer.

#### 1c. Install Required Software

**Option A: Automatic Installation (Recommended)**

```bash
bash scripts/install_dependencies.sh
```

This will:
- Ask for environment name (press Enter for default "atac-seq")
- Take 10-20 minutes
- Install all required tools automatically

**Option B: Use Existing Conda Environment**

If you already have conda:

```bash
conda env create -f environment.yml
conda activate atac-seq
```

#### 1d. Verify Installation

```bash
bash scripts/check_dependencies.sh
```

✅ Should see "All dependencies are satisfied!"

If you see errors, see [INSTALL.md](INSTALL.md) or [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

### Step 2: Prepare Your Data

#### 2a. Organize Your FASTQ Files

Your data should look like this:

```
/path/to/my/data/
├── Sample1_R1_001.fastq.gz    (forward reads)
├── Sample1_R2_001.fastq.gz    (reverse reads)
├── Sample2_R1_001.fastq.gz
├── Sample2_R2_001.fastq.gz
├── Sample3_R1_001.fastq.gz
└── Sample3_R2_001.fastq.gz
```

**Common file naming patterns (all OK):**
- `SampleName_R1.fastq.gz` and `SampleName_R2.fastq.gz`
- `SampleName_1.fastq.gz` and `SampleName_2.fastq.gz`
- `SampleName_R1_001.fastq.gz` and `SampleName_R2_001.fastq.gz`

**If your files have different names:**
You may need to rename them. Ask your sequencing facility for help.

#### 2b. Download Reference Genome (One-Time)

**For human samples (hg19):**

```bash
# Create directory
mkdir -p ~/references/hg19
cd ~/references/hg19

# Download genome (this is ~3 GB, takes 10-30 min)
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
gunzip hg19.fa.gz

# Build index (takes 20-40 min)
mkdir -p bowtie2_index
cd bowtie2_index
bowtie2-build ../hg19.fa hg19

# Download blacklist
cd ~/references/hg19
wget https://github.com/Boyle-Lab/Blacklist/raw/master/lists/hg19-blacklist.v2.bed.gz
gunzip hg19-blacklist.v2.bed.gz

# Download gene annotations
mkdir -p Annotation/Genes
cd Annotation/Genes
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz
gunzip refGene.txt.gz
awk 'BEGIN{OFS="\t"} {print $3,$5,$6,$2,$13,$4}' refGene.txt > genes.bed
```

**For mouse samples (mm10):** See [INSTALL.md](INSTALL.md#download-mouse-genome-mm10)

### Step 3: Configure the Pipeline

#### 3a. Create Configuration File

```bash
cd ~/ATAC-seq-pipeline
cp config.example.sh config.sh
```

#### 3b. Edit Configuration

```bash
nano config.sh
# Or use any text editor you prefer
```

**Change these lines** (use your actual paths):

```bash
# Where to put results
BASE_DIR="/home/YOUR_USERNAME/ATAC_analysis"

# Where your FASTQ files are
RAW_DIR="/path/to/your/fastq/files"

# Reference genome paths
GENOME_INDEX="/home/YOUR_USERNAME/references/hg19/bowtie2_index/hg19"
GENOME_FA="/home/YOUR_USERNAME/references/hg19/hg19.fa"
BLACKLIST="/home/YOUR_USERNAME/references/hg19/hg19-blacklist.v2.bed"
ANNOTATION_DIR="/home/YOUR_USERNAME/references/hg19/Annotation/Genes"
```

**Save and exit:**
- In nano: `Ctrl+X`, then `Y`, then `Enter`

**Don't know your username?**
```bash
whoami
# This shows your username
```

**Don't know the full path to your data?**
```bash
cd /path/to/your/data
pwd
# This shows the full path
```

### Step 4: Run the Pipeline

#### 4a. Activate Environment

```bash
conda activate atac-seq
```

#### 4b. Run Pipeline

```bash
cd ~/ATAC-seq-pipeline
bash ATAC_main.sh
```

**What happens now:**
- Pipeline will print progress messages
- Each step is numbered (1-16)
- Takes 8-48 hours depending on data size
- You can close terminal - it keeps running
- If it stops, just run again - it resumes automatically!

#### 4c. Monitor Progress

**In same terminal:**
```bash
tail -f command_log.txt
# Press Ctrl+C to stop viewing
```

**In new terminal:**
```bash
cd ~/ATAC-seq-pipeline
cat .pipeline_progress
# Shows completed steps
```

### Step 5: Check Results

#### 5a. View Quality Report

```bash
cd ~/ATAC_analysis
firefox multiqc_report/multiqc_report.html
# Or: open multiqc_report/multiqc_report.html
```

**What to look for:**
- Green = good
- Orange = warning
- Red = problem

#### 5b. Check Summary Statistics

```bash
cat final_results/pipeline_summary_stats.tsv
```

**Good quality indicators:**
- Mapping Rate: >90%
- Duplication Rate: <40%
- FRiP Score: >0.3

Compare to test examples:
```bash
cat ~/ATAC-seq-pipeline/test_output/example_summary_stats.tsv
```

#### 5c. View Plots

```bash
cd plots/
ls *.pdf
# Open in file browser or:
evince fragment_size_distribution.pdf
```

**Key plots to check:**
1. `fragment_size_distribution.pdf` - Should show peaks at ~50, 200, 400 bp
2. `TSS_enrichment_profile.pdf` - Should show sharp peak at center
3. `correlation_heatmap.pdf` - Replicates should be >0.9 correlation

### Step 6: Use Your Results

#### Your Main Output Files

```bash
cd ~/ATAC_analysis/final_results

# Main results:
ls -lh ATAC_peaks.filtered.narrowPeak     # Peak locations
ls -lh ATAC_annotated_homer.txt            # Gene associations
ls -lh pipeline_summary_stats.tsv          # QC metrics

# For genome browser:
ls -lh ../bigwig_tracks/*.bw
```

#### Load in Genome Browser (IGV)

1. **Download IGV:** https://software.broadinstitute.org/software/igv/download
2. **Open IGV**
3. **File → Load from File** → Select `.bw` files
4. **Navigate to gene of interest**

#### For Publications

**Files to include:**
- `pipeline_summary_stats.tsv` - Table 1
- `plots/fragment_size_distribution.pdf` - Figure 1
- `plots/TSS_enrichment_profile.pdf` - Figure 2
- `plots/correlation_heatmap.pdf` - Supplementary Figure

## Common Questions

### How long does it take?

- Setup (first time): 2-4 hours
- Running pipeline: 8-48 hours
- Total: Plan for 2-3 days from start to results

### How much does it cost?

- Software: FREE (all open-source)
- Computing: Use your institution's server or ~$50-100 on cloud

### What if something fails?

1. **Check error message** in terminal
2. **Look at logs:**
   ```bash
   tail -100 command_log.txt
   ```
3. **Read troubleshooting:**
   ```bash
   less ~/ATAC-seq-pipeline/TROUBLESHOOTING.md
   ```
4. **Ask for help:**
   - GitHub Issues
   - Your local bioinformatics core
   - Your PI/lab mates

### Can I stop and resume?

**Yes!** The pipeline automatically saves progress.

```bash
# Stop: Press Ctrl+C
# Resume: Just run again
bash ATAC_main.sh
```

### Where are my results?

All in your `BASE_DIR` (set in config.sh):

```bash
cd ~/ATAC_analysis   # Or your BASE_DIR
ls -lh
```

## Next Steps

### Learn More

- **USAGE.md** - Detailed usage guide
- **test_output/PLOT_GUIDE.md** - How to interpret plots
- **TROUBLESHOOTING.md** - Solutions to common problems

### Analyze Your Results

- **Differential accessibility:** Use DESeq2 in R
- **Motif analysis:** HOMER or MEME
- **Pathway analysis:** GREAT or Enrichr

See [USAGE.md#downstream-analysis](USAGE.md#downstream-analysis)

### Get Help

- **Documentation:** Read the docs folder
- **GitHub Issues:** Report bugs
- **Email:** your.email@institution.edu

## Checklist

Use this to track your progress:

- [ ] Installed pipeline
- [ ] Verified dependencies (`check_dependencies.sh`)
- [ ] Downloaded reference genome
- [ ] Organized FASTQ files
- [ ] Created and edited config.sh
- [ ] Ran pipeline successfully
- [ ] Checked MultiQC report
- [ ] Viewed summary statistics
- [ ] Examined plots
- [ ] Compared to test outputs
- [ ] Loaded data in genome browser
- [ ] Ready for publication!

---

## Still Confused?

**That's OK!** Bioinformatics has a learning curve.

**Try this:**
1. Run the test dataset first (smaller, faster)
2. Watch the pipeline work
3. Then try your real data

**Or:**
- Ask your institution's bioinformatics core for help
- Take a bioinformatics workshop
- Read the ATAC-seq paper: [Buenrostro et al. 2013](https://www.nature.com/articles/nmeth.2688)

---

**You've got this! 🎉**

One step at a time, and you'll have publication-ready results soon.
