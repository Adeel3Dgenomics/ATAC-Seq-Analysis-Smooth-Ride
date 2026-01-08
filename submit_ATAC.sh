#!/bin/bash
#SBATCH --job-name "ATAC_pipeline"
#SBATCH --output "ATAC_pipeline_%j.out"
#SBATCH --error "ATAC_pipeline_%j.err"
#SBATCH --partition highmem
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --time 1-00:00:00
#SBATCH --mem 250G
#SBATCH --mail-type END,FAIL
#SBATCH --mail-user=${USER}@yourdomain.edu

# SLURM Submission Script for ATAC-seq Pipeline
# This script submits the main pipeline to the cluster

echo "========================================="
echo "SLURM Job ID: $SLURM_JOB_ID"
echo "Running on node: $SLURM_NODELIST"
echo "Job started at: $(date)"
echo "========================================="

# Load required modules
module load fastqc
module load trim_galore
module load bowtie2/2.5.4
module load samtools
module load picard
module load bedtools
module load deeptools
module load homer
module load genrich
module load subread
module load R/4.1.2
module load multiqc

# Run the main pipeline
bash ATAC_main.sh

# Capture exit status
EXIT_STATUS=$?

echo "========================================="
echo "Job finished at: $(date)"
echo "Exit status: $EXIT_STATUS"
echo "========================================="

exit $EXIT_STATUS
