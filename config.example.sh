#!/bin/bash

# =============================================================================
# ATAC-seq Pipeline Configuration File
# =============================================================================
# Copy this file to 'config.sh' and edit with your specific paths
# cp config.example.sh config.sh

# =============================================================================
# DIRECTORY CONFIGURATION
# =============================================================================

# Base directory for analysis output (all results will be created here)
# Example: /home/username/ATAC_analysis or /data/projects/ATAC_Study1
BASE_DIR="/path/to/your/analysis/directory"

# Raw data directory containing FASTQ files
# Files should be named: SampleName_R1_001.fastq.gz and SampleName_R2_001.fastq.gz
# Example: /data/raw_sequencing/Run123
RAW_DIR="/path/to/raw/fastq/files"

# =============================================================================
# REFERENCE GENOME CONFIGURATION
# =============================================================================

# Path to Bowtie2 index (prefix without file extensions like .1.bt2)
# Example: /home/refs/hg19/bowtie2_index/hg19
GENOME_INDEX="/path/to/bowtie2_index/hg19/hg19"

# Path to reference genome FASTA file
# Example: /home/refs/hg19/hg19.fa
GENOME_FA="/path/to/reference/hg19/hg19.fa"

# Path to blacklist regions BED file
# Download from: https://github.com/Boyle-Lab/Blacklist
# Example: /home/refs/hg19/hg19-blacklist.v2.bed
BLACKLIST="/path/to/hg19-blacklist.bed"

# Path to annotation directory containing gene annotations
# Should contain: genes.gtf, genes.bed, and/or refGene.txt
# Example: /home/refs/hg19/Annotation/Genes
ANNOTATION_DIR="/path/to/annotation/hg19/Genes"

# =============================================================================
# COMPUTATIONAL PARAMETERS
# =============================================================================

# Number of threads/CPU cores to use
# Recommended: Use all available cores minus 1-2 for system processes
# Check available cores: nproc or lscpu
THREADS=8

# Effective genome size for normalization (used by deepTools)
# Common values:
#   hg19 (GRCh37): 3137144693
#   hg38 (GRCh38): 3099750718
#   mm10 (GRCm38): 2652783500
#   mm9  (NCBI37): 2620345972
#   dm6  (BDGP6):  142573017
#   ce10 (WS220):   100286401
EFFECTIVE_GENOME_SIZE=3137144693

# =============================================================================
# ADAPTER AND TRIMMING PARAMETERS
# =============================================================================

# Adapter sequence for trimming
# Common adapters:
#   Nextera (ATAC-seq standard): CTGTCTCTTATA
#   TruSeq: AGATCGGAAGAGC
#   Nextera transposase: CTGTCTCTTATACACATCT
ADAPTER="CTGTCTCTTATA"

# Quality score threshold for trimming (Phred score)
QUALITY_THRESHOLD=20

# Minimum read length after trimming
MIN_LENGTH=20

# =============================================================================
# ALIGNMENT PARAMETERS
# =============================================================================

# Bowtie2 alignment mode
# Options: --very-fast, --fast, --sensitive, --very-sensitive
ALIGNMENT_MODE="--very-sensitive"

# Allow dovetail reads (recommended for ATAC-seq)
DOVETAIL="--dovetail"

# Minimum fragment size (insert size)
MIN_INSERT=10

# Maximum fragment size (insert size)
MAX_INSERT=1000

# =============================================================================
# PEAK CALLING PARAMETERS
# =============================================================================

# Genrich q-value threshold (FDR)
# More stringent: 0.01, Less stringent: 0.1
QVALUE_THRESHOLD=0.05

# Exclude chromosomes from peak calling (comma-separated)
# Common: chrM (mitochondrial), chrY, or random/unknown contigs
EXCLUDE_CHROMOSOMES="chrM"

# =============================================================================
# SAMPLE GROUPING (for peak calling)
# =============================================================================

# If you want to call peaks on specific sample groups, list them here
# Leave empty to use all samples
# Example: SAMPLES_GROUP1="Sample1 Sample2 Sample3"
SAMPLES_GROUP1=""
SAMPLES_GROUP2=""

# =============================================================================
# OPTIONAL ADVANCED PARAMETERS
# =============================================================================

# Remove duplicates with Picard (true/false)
REMOVE_DUPLICATES=true

# Keep intermediate files (true/false)
# Set to false to save disk space after successful run
KEEP_INTERMEDIATE=true

# Email notification (if using SLURM)
EMAIL=""

# Custom temporary directory (useful for large files)
# Leave empty to use default system temp
TMPDIR=""

# =============================================================================
# REFERENCE GENOME QUICK SETUP
# =============================================================================
# Uncomment one of the following pre-configured genome setups:

# --- Human hg19 (GRCh37) ---
# GENOME_INDEX="/data/refs/hg19/bowtie2/hg19"
# GENOME_FA="/data/refs/hg19/hg19.fa"
# BLACKLIST="/data/refs/hg19/hg19-blacklist.v2.bed"
# ANNOTATION_DIR="/data/refs/hg19/Annotation/Genes"
# EFFECTIVE_GENOME_SIZE=3137144693

# --- Human hg38 (GRCh38) ---
# GENOME_INDEX="/data/refs/hg38/bowtie2/hg38"
# GENOME_FA="/data/refs/hg38/hg38.fa"
# BLACKLIST="/data/refs/hg38/hg38-blacklist.v2.bed"
# ANNOTATION_DIR="/data/refs/hg38/Annotation/Genes"
# EFFECTIVE_GENOME_SIZE=3099750718

# --- Mouse mm10 (GRCm38) ---
# GENOME_INDEX="/data/refs/mm10/bowtie2/mm10"
# GENOME_FA="/data/refs/mm10/mm10.fa"
# BLACKLIST="/data/refs/mm10/mm10-blacklist.v2.bed"
# ANNOTATION_DIR="/data/refs/mm10/Annotation/Genes"
# EFFECTIVE_GENOME_SIZE=2652783500

# --- Mouse mm9 (NCBI37) ---
# GENOME_INDEX="/data/refs/mm9/bowtie2/mm9"
# GENOME_FA="/data/refs/mm9/mm9.fa"
# BLACKLIST="/data/refs/mm9/mm9-blacklist.bed"
# ANNOTATION_DIR="/data/refs/mm9/Annotation/Genes"
# EFFECTIVE_GENOME_SIZE=2620345972

# =============================================================================
# DO NOT EDIT BELOW THIS LINE (unless you know what you're doing)
# =============================================================================

# Auto-create output directories if they don't exist
TRIM_DIR="$BASE_DIR/trimmed_data"
QC_DIR="$BASE_DIR/QC"
ALIGN_DIR="$BASE_DIR/alignment"
DEDUP_DIR="$ALIGN_DIR/dedup"
PEAK_DIR="$BASE_DIR/peaks"
BLACKLIST_DIR="$BASE_DIR/blacklist_removed"
BIGWIG_DIR="$BASE_DIR/bigwig_tracks"
FINAL_RESULTS="$BASE_DIR/final_results"
MULTIQC_DIR="$BASE_DIR/multiqc_report"
PLOT_DIR="$BASE_DIR/plots"

# Export all variables for use in main script
export BASE_DIR RAW_DIR GENOME_INDEX GENOME_FA BLACKLIST ANNOTATION_DIR
export THREADS EFFECTIVE_GENOME_SIZE ADAPTER QUALITY_THRESHOLD MIN_LENGTH
export ALIGNMENT_MODE DOVETAIL MIN_INSERT MAX_INSERT
export QVALUE_THRESHOLD EXCLUDE_CHROMOSOMES
export TRIM_DIR QC_DIR ALIGN_DIR DEDUP_DIR PEAK_DIR
export BLACKLIST_DIR BIGWIG_DIR FINAL_RESULTS MULTIQC_DIR PLOT_DIR
