#!/bin/bash

# ATAC-seq Analysis Pipeline - Main Script
# This is the main computational pipeline that can be run standalone or via SLURM

# Set random seeds for reproducibility
export PYTHONHASHSEED=0
export R_RANDOM_SEED=42

# Function to check and install R packages
install_r_packages() {
    R --vanilla --quiet --slave <<'RSCRIPT' >/dev/null 2>&1
# Set local library path
local_lib <- file.path(Sys.getenv("HOME"), "R_libs")
if (!dir.exists(local_lib)) {
    dir.create(local_lib, recursive = TRUE)
}
.libPaths(c(local_lib, .libPaths()))

# Required packages
required_packages <- c("ggplot2", "dplyr", "tidyr")

# Check and install silently
for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        install.packages(pkg, lib = local_lib, repos = "https://cloud.r-project.org", quiet = TRUE)
    }
}
RSCRIPT
}

# Function to log versions and commands for reproducibility
log_reproducibility() {
    local repro_log="$BASE_DIR/reproducibility_log.txt"
    
    if [ ! -f "$repro_log" ]; then
        echo "===========================================" > $repro_log
        echo "ATAC-seq Pipeline Reproducibility Log" >> $repro_log
        echo "===========================================" >> $repro_log
        echo "" >> $repro_log
        echo "Run Date: $(date)" >> $repro_log
        echo "User: $(whoami)" >> $repro_log
        echo "Hostname: $(hostname)" >> $repro_log
        echo "Working Directory: $(pwd)" >> $repro_log
        echo "" >> $repro_log
        
        echo "-------------------------------------------" >> $repro_log
        echo "Software Versions:" >> $repro_log
        echo "-------------------------------------------" >> $repro_log
        echo "Bash: $BASH_VERSION" >> $repro_log
        fastqc --version 2>&1 | head -1 >> $repro_log 2>&1 || echo "FastQC: Not available" >> $repro_log
        trim_galore --version 2>&1 | head -1 >> $repro_log 2>&1 || echo "Trim Galore: Not available" >> $repro_log
        bowtie2 --version 2>&1 | head -1 >> $repro_log 2>&1 || echo "Bowtie2: Not available" >> $repro_log
        samtools --version 2>&1 | head -1 >> $repro_log 2>&1 || echo "Samtools: Not available" >> $repro_log
        echo "Picard: $(picard MarkDuplicates --version 2>&1 || echo 'Version unknown')" >> $repro_log
        bedtools --version 2>&1 >> $repro_log 2>&1 || echo "BEDTools: Not available" >> $repro_log
        echo "deepTools: $(bamCoverage --version 2>&1 || echo 'Version unknown')" >> $repro_log
        echo "HOMER: $(annotatePeaks.pl 2>&1 | grep -i version | head -1 || echo 'Version unknown')" >> $repro_log
        Genrich -h 2>&1 | head -3 >> $repro_log 2>&1 || echo "Genrich: Not available" >> $repro_log
        featureCounts -v 2>&1 | head -1 >> $repro_log 2>&1 || echo "featureCounts: Not available" >> $repro_log
        multiqc --version 2>&1 >> $repro_log 2>&1 || echo "MultiQC: Not available" >> $repro_log
        R --version 2>&1 | head -1 >> $repro_log 2>&1 || echo "R: Not available" >> $repro_log
        
        echo "" >> $repro_log
        echo "-------------------------------------------" >> $repro_log
        echo "R Package Versions:" >> $repro_log
        echo "-------------------------------------------" >> $repro_log
        R --vanilla --quiet --slave -e "local_lib <- file.path(Sys.getenv('HOME'), 'R_libs'); .libPaths(c(local_lib, .libPaths())); pkgs <- c('ggplot2', 'dplyr', 'tidyr'); for(p in pkgs) { if(requireNamespace(p, quietly=TRUE)) cat(p, ': ', as.character(packageVersion(p)), '\\n', sep='') }" 2>/dev/null >> $repro_log
        
        echo "" >> $repro_log
        echo "-------------------------------------------" >> $repro_log
        echo "Pipeline Parameters:" >> $repro_log
        echo "-------------------------------------------" >> $repro_log
        echo "BASE_DIR: $BASE_DIR" >> $repro_log
        echo "RAW_DIR: $RAW_DIR" >> $repro_log
        echo "GENOME_INDEX: $GENOME_INDEX" >> $repro_log
        echo "GENOME_FA: $GENOME_FA" >> $repro_log
        echo "BLACKLIST: $BLACKLIST" >> $repro_log
        echo "ANNOTATION_DIR: $ANNOTATION_DIR" >> $repro_log
        echo "Effective Genome Size: 3137144693" >> $repro_log
        echo "Threads: 8" >> $repro_log
        echo "Adapter Sequence: CTGTCTCTTATA" >> $repro_log
        echo "" >> $repro_log
        
        echo "-------------------------------------------" >> $repro_log
        echo "Bowtie2 Parameters:" >> $repro_log
        echo "-------------------------------------------" >> $repro_log
        echo "Mode: --very-sensitive" >> $repro_log
        echo "Dovetail: enabled" >> $repro_log
        echo "Min insert size (-I): 10" >> $repro_log
        echo "Max insert size (-X): 1000" >> $repro_log
        echo "" >> $repro_log
        
        echo "-------------------------------------------" >> $repro_log
        echo "Genrich Parameters:" >> $repro_log
        echo "-------------------------------------------" >> $repro_log
        echo "Mode: ATAC-seq (-j)" >> $repro_log
        echo "Keep duplicates: yes (-y)" >> $repro_log
        echo "Remove PCR duplicates: yes (-r)" >> $repro_log
        echo "Verbose: yes (-v)" >> $repro_log
        echo "Exclude chrM: yes (-e chrM)" >> $repro_log
        echo "" >> $repro_log
        
        echo "-------------------------------------------" >> $repro_log
        echo "File MD5 Checksums (Input Files):" >> $repro_log
        echo "-------------------------------------------" >> $repro_log
        for file in $RAW_DIR/*_R1_001.fastq.gz; do
            if [ -f "$file" ]; then
                md5sum "$file" >> $repro_log 2>&1 || echo "Could not generate checksum for $file" >> $repro_log
            fi
        done
        echo "" >> $repro_log
        
        echo "Reference Genome Checksum:" >> $repro_log
        if [ -f "$GENOME_FA" ]; then
            md5sum "$GENOME_FA" >> $repro_log 2>&1 || echo "Could not generate checksum" >> $repro_log
        fi
        echo "" >> $repro_log
        
        echo "===========================================" >> $repro_log
        echo "" >> $repro_log
    fi
}

# Function to log command execution
log_command() {
    local step=$1
    local command=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Step: $step" >> $BASE_DIR/command_log.txt
    echo "Command: $command" >> $BASE_DIR/command_log.txt
    echo "" >> $BASE_DIR/command_log.txt
}

# Function to mark step as complete
mark_step_complete() {
    local step_name=$1
    echo "$(date): $step_name" >> $BASE_DIR/.pipeline_progress
    echo "✓ Step completed: $step_name"
}

# Function to check if step is complete
is_step_complete() {
    local step_name=$1
    if [ -f "$BASE_DIR/.pipeline_progress" ]; then
        grep -q "$step_name" $BASE_DIR/.pipeline_progress
        return $?
    fi
    return 1
}

# Function to check chromosome naming convention
check_chr_naming() {
    local file=$1
    
    if [[ $file == *.bam ]]; then
        first_chr=$(samtools view -H $file 2>/dev/null | grep "^@SQ" | head -1 | cut -f2 | cut -d: -f2)
    elif [[ $file == *.bed ]] || [[ $file == *.narrowPeak ]]; then
        first_chr=$(head -1 $file 2>/dev/null | cut -f1)
    elif [[ $file == *.fa ]] || [[ $file == *.fasta ]]; then
        first_chr=$(grep "^>" $file 2>/dev/null | head -1 | sed 's/>//g' | cut -d' ' -f1)
    else
        return 1
    fi
    
    if [[ $first_chr == chr* ]]; then
        echo "WITH_CHR"
    else
        echo "WITHOUT_CHR"
    fi
}

# Function to fix chromosome naming if needed
fix_chr_naming() {
    local input_file=$1
    local output_file=$2
    local target_format=$3
    
    if [[ $input_file == *.bed ]] || [[ $input_file == *.narrowPeak ]]; then
        if [ "$target_format" == "WITH_CHR" ]; then
            awk 'BEGIN{OFS="\t"} {if($1 !~ /^chr/) $1="chr"$1; print}' $input_file > $output_file 2>/dev/null
        else
            awk 'BEGIN{OFS="\t"} {gsub(/^chr/, "", $1); print}' $input_file > $output_file 2>/dev/null
        fi
    fi
}

# Set directories
BASE_DIR="$PWD"
RAW_DIR="/archive/nath/LW_Expt_93_ATACseq_GM12878/22YVHWLT4"
TRIM_DIR="$BASE_DIR/trimmed_data"
QC_DIR="$BASE_DIR/QC"
ALIGN_DIR="$BASE_DIR/alignment"
DEDUP_DIR="$ALIGN_DIR/dedup"
PEAK_DIR="$BASE_DIR/peaks"
BLACKLIST_DIR="$BASE_DIR/blacklist_removed"
BIGWIG_DIR="$BASE_DIR/bigwig_tracks"
FINAL_RESULTS="$BASE_DIR/final_results"
MULTIQC_DIR="$BASE_DIR/multiqc_report"

# Make directories
mkdir -p $TRIM_DIR $QC_DIR/raw $QC_DIR/trimmed  $ALIGN_DIR $DEDUP_DIR $PEAK_DIR $BLACKLIST_DIR $BIGWIG_DIR $FINAL_RESULTS $MULTIQC_DIR

# Initialize reproducibility log
log_reproducibility

# Check for resume
if [ -f "$BASE_DIR/.pipeline_progress" ]; then
    echo "====================================="
    echo "RESUMING PIPELINE FROM PREVIOUS RUN"
    echo "====================================="
    echo "Previous progress:"
    cat $BASE_DIR/.pipeline_progress
    echo "====================================="
else
    echo "Starting fresh pipeline run"
fi

# Check and install R packages
install_r_packages

# Reference genome
GENOME_INDEX="/Volumes/shared-refs/bowtie2_index/hg19/hg19"
GENOME_FA="/Volumes/shared-refs/bowtie2_index/hg19/hg19.fa"
BLACKLIST="$BASE_DIR/hg19-blacklist.bed"
ANNOTATION_DIR="/s/nath-lab/adeel/HiCAR/reference/hg19/Annotation/Genes"

# Silent chromosome naming compatibility check and fix
if [ -f "$GENOME_FA" ]; then
    REF_CHR_FORMAT=$(check_chr_naming $GENOME_FA 2>/dev/null)
else
    REF_CHR_FORMAT="UNKNOWN"
fi

if [ -f "$BLACKLIST" ]; then
    BL_CHR_FORMAT=$(check_chr_naming $BLACKLIST 2>/dev/null)
    if [ "$REF_CHR_FORMAT" != "UNKNOWN" ] && [ "$BL_CHR_FORMAT" != "$REF_CHR_FORMAT" ]; then
        fix_chr_naming $BLACKLIST ${BLACKLIST}.fixed $REF_CHR_FORMAT 2>/dev/null
        BLACKLIST=${BLACKLIST}.fixed
    fi
fi

if [ -f "$ANNOTATION_DIR/genes.bed" ]; then
    ANNOT_CHR_FORMAT=$(check_chr_naming $ANNOTATION_DIR/genes.bed 2>/dev/null)
    if [ "$REF_CHR_FORMAT" != "UNKNOWN" ] && [ "$ANNOT_CHR_FORMAT" != "$REF_CHR_FORMAT" ]; then
        mkdir -p $PLOT_DIR
        fix_chr_naming $ANNOTATION_DIR/genes.bed $PLOT_DIR/genes.fixed.bed $REF_CHR_FORMAT 2>/dev/null
        GENES_BED=$PLOT_DIR/genes.fixed.bed
    else
        GENES_BED=$ANNOTATION_DIR/genes.bed
    fi
fi

# Step 1: Run FastQC on raw data
if is_step_complete "step1_fastqc_raw"; then
    echo "Skipping Step 1: FastQC on raw data (already completed)"
else
    echo "Running FastQC on raw reads..."
    rm -f $QC_DIR/raw/*  # Clean any partial results
    fastqc $RAW_DIR/*.fastq.gz -o $QC_DIR/raw && mark_step_complete "step1_fastqc_raw"
fi

# Step 2: Trim adapters and low-quality reads
if is_step_complete "step2_trim_galore"; then
    echo "Skipping Step 2: Trim Galore (already completed)"
else
    echo "Trimming reads with Trim Galore..."
    rm -f $TRIM_DIR/*  # Clean any partial results
    for sample in $RAW_DIR/*_R1_001.fastq.gz; do
      base=$(basename $sample _R1_001.fastq.gz)
      cmd="trim_galore --paired --fastqc --adapter CTGTCTCTTATA --output_dir $TRIM_DIR $RAW_DIR/${base}_R1_001.fastq.gz $RAW_DIR/${base}_R2_001.fastq.gz"
      log_command "step2_trim_galore" "$cmd"
      trim_galore --paired --fastqc --adapter CTGTCTCTTATA --output_dir $TRIM_DIR \
            $RAW_DIR/${base}_R1_001.fastq.gz $RAW_DIR/${base}_R2_001.fastq.gz
    done
    mark_step_complete "step2_trim_galore"
fi

# Step 3: Run FastQC on trimmed reads
if is_step_complete "step3_fastqc_trimmed"; then
    echo "Skipping Step 3: FastQC on trimmed reads (already completed)"
else
    fastqc $TRIM_DIR/*.fq.gz -o $QC_DIR/trimmed && mark_step_complete "step3_fastqc_trimmed"
fi

# Step 4: Run MultiQC to summarize FastQC results

if is_step_complete "step4_multiqc_qc"; then
    echo "Skipping Step 4: MultiQC for QC (already completed)"
else
    echo "Running MultiQC for QC summary..."
    multiqc $QC_DIR -o $MULTIQC_DIR --force && mark_step_complete "step4_multiqc_qc"
fi


# Step 5: Align reads to reference genome using Bowtie2
if is_step_complete "step5_alignment"; then
    echo "Skipping Step 5: Alignment (already completed)"
else
    echo "Aligning reads with Bowtie2..."
    rm -f $ALIGN_DIR/*.bam*  # Clean any partial results
    if [ ! -f "$GENOME_INDEX.1.bt2" ]; then
        bowtie2-build $GENOME_FA $GENOME_INDEX
    fi

    for sample in $TRIM_DIR/*_R1_001_val_1.fq.gz; do
     base=$(basename $sample _R1_001_val_1.fq.gz)
     cmd="bowtie2 -x $GENOME_INDEX -1 $TRIM_DIR/${base}_R1_001_val_1.fq.gz -2 $TRIM_DIR/${base}_R2_001_val_2.fq.gz --very-sensitive --dovetail -I 10 -X 1000 -p 8"
     log_command "step5_alignment" "$cmd"
     bowtie2 -x $GENOME_INDEX -1 $TRIM_DIR/${base}_R1_001_val_1.fq.gz -2 $TRIM_DIR/${base}_R2_001_val_2.fq.gz \
            --very-sensitive --dovetail -I 10 -X 1000 -p 8 | samtools view -bS - | samtools sort -o $ALIGN_DIR/${base}.sorted.bam
    done
    mark_step_complete "step5_alignment"
fi

# Step 6: Index BAM files
if is_step_complete "step6_index_bam"; then
    echo "Skipping Step 6: BAM indexing (already completed)"
else
    for bam in $ALIGN_DIR/*.sorted.bam; do
        samtools index $bam
    done
    
    # Silent chromosome naming check in BAM files
    first_bam=$(ls $ALIGN_DIR/*.sorted.bam 2>/dev/null | head -1)
    if [ -f "$first_bam" ]; then
        BAM_CHR_FORMAT=$(check_chr_naming $first_bam 2>/dev/null)
    fi
    
    mark_step_complete "step6_index_bam"
fi

# Step 7: Remove duplicates using Picard
if is_step_complete "step7_deduplication"; then
    echo "Skipping Step 7: Deduplication (already completed)"
else
    echo "Removing duplicates with Picard..."
    rm -f $DEDUP_DIR/*.bam*  # Clean any partial results
    for bam in $ALIGN_DIR/*.sorted.bam; do
        base=$(basename $bam .sorted.bam)
        picard MarkDuplicates I=$bam O=$DEDUP_DIR/${base}.dedup.bam M=$DEDUP_DIR/${base}_dup_metrics.txt REMOVE_DUPLICATES=true
        samtools index $DEDUP_DIR/${base}.dedup.bam
    done
    mark_step_complete "step7_deduplication"
fi

# Step 8: Run MultiQC to summarize alignment and deduplication stats
if is_step_complete "step8_multiqc_align"; then
    echo "Skipping Step 8: MultiQC for alignment (already completed)"
else
    multiqc $ALIGN_DIR $DEDUP_DIR -o $MULTIQC_DIR --force && mark_step_complete "step8_multiqc_align"
fi
# Step 7.a sorting by name

if is_step_complete "step7a_sort_by_name"; then
    echo "Skipping Step 7a: Sort by name (already completed)"
else
    for f in ${DEDUP_DIR}/*.dedup.bam; do
      base=$(basename "$f" .dedup.bam)
      samtools sort -n -@ 8 -o ${DEDUP_DIR}/${base}.qnamesort.bam $f
    done
    mark_step_complete "step7a_sort_by_name"
fi

# Step 9: Peak calling with Genrich
if is_step_complete "step9_peak_calling"; then
    echo "Skipping Step 9: Peak calling (already completed)"
else
    echo "Running Genrich for peak calling..."
    rm -f $PEAK_DIR/*  # Clean any partial results
    cmd="Genrich -t ${DEDUP_DIR}/2_S11.qnamesort.bam,${DEDUP_DIR}/3_S12.qnamesort.bam,${DEDUP_DIR}/4_S13.qnamesort.bam -o $PEAK_DIR/ATAC_peaks.narrowPeak -j -y -r -v -e chrM"
    log_command "step9_peak_calling" "$cmd"
    Genrich -t ${DEDUP_DIR}/2_S11.qnamesort.bam,${DEDUP_DIR}/3_S12.qnamesort.bam,${DEDUP_DIR}/4_S13.qnamesort.bam -o $PEAK_DIR/ATAC_peaks.narrowPeak -j -y -r -v -e chrM
    mark_step_complete "step9_peak_calling"
fi


# Step 10: Remove blacklisted regions
if is_step_complete "step10_blacklist_filter"; then
    echo "Skipping Step 10: Blacklist filtering (already completed)"
else
    echo "Removing blacklisted regions..."
    rm -f $BLACKLIST_DIR/*  # Clean any partial results
    bedtools intersect -v -a $PEAK_DIR/ATAC_peaks.narrowPeak -b $BLACKLIST > $BLACKLIST_DIR/ATAC_peaks.filtered.narrowPeak
    mark_step_complete "step10_blacklist_filter"
fi

# Step 10a: Calculate FRiP (Fraction of Reads in Peaks) for each sample
if is_step_complete "step10a_frip"; then
    echo "Skipping Step 10a: FRiP calculation (already completed)"
else
    echo "Calculating FRiP scores..."
    mkdir -p $FINAL_RESULTS/frip
    rm -f $FINAL_RESULTS/frip/frip_scores.txt  # Clean any partial results
    for bam in $DEDUP_DIR/*.dedup.bam; do
        base=$(basename $bam .dedup.bam)
        # Count reads in peaks
        reads_in_peaks=$(bedtools intersect -a $bam -b $BLACKLIST_DIR/ATAC_peaks.filtered.narrowPeak -u | samtools view -c)
        # Count total mapped reads
        total_reads=$(samtools view -c -F 4 $bam)
        # Calculate FRiP
        if [ "$total_reads" -gt 0 ]; then
            frip=$(echo "scale=4; $reads_in_peaks / $total_reads" | bc)
        else
            frip="NA"
        fi
        echo -e "${base}\t${reads_in_peaks}\t${total_reads}\t${frip}" >> $FINAL_RESULTS/frip/frip_scores.txt
        echo "Sample: $base - FRiP: $frip"
    done
    mark_step_complete "step10a_frip"
fi

# Step 11: Annotate peaks using HOMER and additional annotations
if is_step_complete "step11_annotation"; then
    echo "Skipping Step 11: Peak annotation (already completed)"
else
    echo "Annotating peaks..."
    # HOMER annotation
    annotatePeaks.pl $BLACKLIST_DIR/ATAC_peaks.filtered.narrowPeak hg19 > $FINAL_RESULTS/ATAC_annotated_homer.txt

    # Additional annotation with genes.gtf
    if [ -f "$ANNOTATION_DIR/genes.gtf" ]; then
        bedtools intersect -a $BLACKLIST_DIR/ATAC_peaks.filtered.narrowPeak -b $ANNOTATION_DIR/genes.gtf -wa -wb > $FINAL_RESULTS/ATAC_peaks_genes_overlap.txt
    fi

    # Annotation with refGene.txt
    if [ -f "$ANNOTATION_DIR/refGene.txt" ]; then
        bedtools closest -a $BLACKLIST_DIR/ATAC_peaks.filtered.narrowPeak -b $ANNOTATION_DIR/genes.bed -d > $FINAL_RESULTS/ATAC_peaks_closest_genes.txt
    fi

    # Create summary of peak distribution relative to genomic features
    echo "Creating peak annotation summary..."
    awk 'NR>1 {print $8}' $FINAL_RESULTS/ATAC_annotated_homer.txt | sort | uniq -c | sort -rn > $FINAL_RESULTS/peak_distribution_summary.txt
    mark_step_complete "step11_annotation"
fi

# Step 12: Convert BAM to BigWig for visualization
if is_step_complete "step12_bigwig"; then
    echo "Skipping Step 12: BigWig generation (already completed)"
else
    echo "Generating BigWig files..."
    rm -f $BIGWIG_DIR/*  # Clean any partial results
    for bam in $DEDUP_DIR/*.dedup.bam; do
    base=$(basename $bam .dedup.bam)
        bamCoverage --bam $bam -o $BIGWIG_DIR/${base}.bw --normalizeUsing RPGC --effectiveGenomeSize 3137144693
    done
    mark_step_complete "step12_bigwig"
fi

# Step 13: Count reads in peaks for differential analysis
if is_step_complete "step13_featurecounts"; then
    echo "Skipping Step 13: Feature counting (already completed)"
else
    echo "Counting reads in peaks..."
    featureCounts -T 8 -p -a $BLACKLIST_DIR/ATAC_peaks.filtered.narrowPeak -o $FINAL_RESULTS/counts.txt $DEDUP_DIR/*.dedup.bam
    mark_step_complete "step13_featurecounts"
fi


# Step 14: Generate summary statistics table
if is_step_complete "step14_summary_stats"; then
    echo "Skipping Step 14: Summary statistics (already completed)"
else
    echo "Generating summary statistics table..."
    SUMMARY_TABLE="$FINAL_RESULTS/pipeline_summary_stats.tsv"

# Create header
echo -e "Sample\tRaw_Reads\tTrimmed_Reads\tMapped_Reads\tMapping_Rate(%)\tReads_Before_Dedup\tReads_After_Dedup\tDuplication_Rate(%)\tFRiP\tPeaks" > $SUMMARY_TABLE

# Process each sample
for sample in $RAW_DIR/*_R1_001.fastq.gz; do
    base=$(basename $sample _R1_001.fastq.gz)
    
    # Count raw reads (divide by 4 for fastq, multiply by 2 for paired-end)
    if [ -f "$RAW_DIR/${base}_R1_001.fastq.gz" ]; then
        raw_reads=$(zcat $RAW_DIR/${base}_R1_001.fastq.gz | echo $((`wc -l`/4)))
    else
        raw_reads="NA"
    fi
    
    # Count trimmed reads
    if [ -f "$TRIM_DIR/${base}_R1_001_val_1.fq.gz" ]; then
        trimmed_reads=$(zcat $TRIM_DIR/${base}_R1_001_val_1.fq.gz | echo $((`wc -l`/4)))
    else
        trimmed_reads="NA"
    fi
    
    # Get mapped reads from sorted BAM
    if [ -f "$ALIGN_DIR/${base}.sorted.bam" ]; then
        mapped_reads=$(samtools view -c -F 4 $ALIGN_DIR/${base}.sorted.bam)
        total_aligned=$(samtools view -c $ALIGN_DIR/${base}.sorted.bam)
        if [ "$total_aligned" -gt 0 ]; then
            mapping_rate=$(echo "scale=2; $mapped_reads * 100 / $total_aligned" | bc)
        else
            mapping_rate="NA"
        fi
    else
        mapped_reads="NA"
        mapping_rate="NA"
    fi
    
    # Get reads before deduplication
    if [ -f "$ALIGN_DIR/${base}.sorted.bam" ]; then
        reads_before_dedup=$(samtools view -c $ALIGN_DIR/${base}.sorted.bam)
    else
        reads_before_dedup="NA"
    fi
    
    # Get reads after deduplication and calculate duplication rate
    if [ -f "$DEDUP_DIR/${base}.dedup.bam" ]; then
        reads_after_dedup=$(samtools view -c $DEDUP_DIR/${base}.dedup.bam)
        if [ "$reads_before_dedup" != "NA" ] && [ "$reads_before_dedup" -gt 0 ]; then
            duplicates=$((reads_before_dedup - reads_after_dedup))
            dup_rate=$(echo "scale=2; $duplicates * 100 / $reads_before_dedup" | bc)
        else
            dup_rate="NA"
        fi
    else
        reads_after_dedup="NA"
        dup_rate="NA"
    fi
    
    # Get FRiP score
    if [ -f "$FINAL_RESULTS/frip/frip_scores.txt" ]; then
        frip=$(grep "^${base}" $FINAL_RESULTS/frip/frip_scores.txt | cut -f4)
        if [ -z "$frip" ]; then
            frip="NA"
        fi
    else
        frip="NA"
    fi
    
    # Add row to table
    echo -e "$base\t$raw_reads\t$trimmed_reads\t$mapped_reads\t$mapping_rate\t$reads_before_dedup\t$reads_after_dedup\t$dup_rate\t$frip\tNA" >> $SUMMARY_TABLE
done

# Count total peaks
if [ -f "$BLACKLIST_DIR/ATAC_peaks.filtered.narrowPeak" ]; then
    total_peaks=$(wc -l < $BLACKLIST_DIR/ATAC_peaks.filtered.narrowPeak)
else
    total_peaks="NA"
fi

# Add peak count to summary
echo -e "\nTotal Peaks (All Samples Combined):\t$total_peaks" >> $SUMMARY_TABLE

echo "Summary statistics saved to $SUMMARY_TABLE"
mark_step_complete "step14_summary_stats"
fi

# Step 15: Generate plots and visualizations
if is_step_complete "step15_plotting"; then
    echo "Skipping Step 15: Plotting (already completed)"
else
    echo "Generating plots and visualizations..."
    PLOT_DIR="$BASE_DIR/plots"
    mkdir -p $PLOT_DIR

# 15a: Fragment size distribution plot
echo "Plotting fragment size distribution..."
for bam in $DEDUP_DIR/*.dedup.bam; do
    base=$(basename $bam .dedup.bam)
    samtools view $bam | awk '$9>0 {print $9}' | head -1000000 > $PLOT_DIR/${base}_fragment_sizes.txt
done

# Create R script for fragment size plot
cat > $PLOT_DIR/plot_fragment_sizes.R << 'EOF'
library(ggplot2)
library(dplyr)

# Get all fragment size files
files <- list.files(".", pattern="_fragment_sizes.txt$", full.names=TRUE)
all_data <- data.frame()

for(file in files) {
    sample <- gsub("_fragment_sizes.txt", "", basename(file))
    data <- read.table(file, header=FALSE, col.names="FragmentSize")
    data$Sample <- sample
    all_data <- rbind(all_data, data)
}

# Filter to reasonable fragment sizes
all_data <- all_data %>% filter(FragmentSize > 0 & FragmentSize < 1000)

# Plot
p <- ggplot(all_data, aes(x=FragmentSize, color=Sample)) +
    geom_density(size=1.2) +
    theme_bw() +
    labs(title="Fragment Size Distribution", x="Fragment Size (bp)", y="Density") +
    theme(plot.title = element_text(hjust=0.5, size=16, face="bold"),
          legend.position="right")
ggsave("fragment_size_distribution.pdf", p, width=10, height=6)
ggsave("fragment_size_distribution.png", p, width=10, height=6, dpi=300)
EOF

# 15b: TSS enrichment plot
echo "Generating TSS enrichment plot..."
# Create TSS-only BED file (single nucleotide positions)
if [ -f "${GENES_BED:-$ANNOTATION_DIR/genes.bed}" ]; then
    # Extract TSS positions (single nucleotide) based on strand
    awk 'BEGIN{OFS="\t"} {if($6=="+") print $1,$2,$2+1,$4,$5,$6; else print $1,$3-1,$3,$4,$5,$6}' \
        ${GENES_BED:-$ANNOTATION_DIR/genes.bed} > $PLOT_DIR/TSS_positions.bed
    
    computeMatrix reference-point --referencePoint center \
        -b 3000 -a 3000 \
        -R $PLOT_DIR/TSS_positions.bed \
        -S $BIGWIG_DIR/*.bw \
        --skipZeros \
        -o $PLOT_DIR/matrix_TSS.gz \
        --outFileSortedRegions $PLOT_DIR/genes_TSS.bed
    
    plotProfile -m $PLOT_DIR/matrix_TSS.gz \
        -out $PLOT_DIR/TSS_enrichment_profile.pdf \
        --plotTitle "TSS Enrichment" \
        --perGroup \
        --colors red blue green
    
    plotProfile -m $PLOT_DIR/matrix_TSS.gz \
        -out $PLOT_DIR/TSS_enrichment_profile.png \
        --plotTitle "TSS Enrichment" \
        --perGroup \
        --colors red blue green
    
    plotHeatmap -m $PLOT_DIR/matrix_TSS.gz \
        -out $PLOT_DIR/TSS_heatmap.pdf \
        --colorMap RdYlBu \
        --whatToShow 'heatmap and colorbar'
    
    plotHeatmap -m $PLOT_DIR/matrix_TSS.gz \
        -out $PLOT_DIR/TSS_heatmap.png \
        --colorMap RdYlBu \
        --whatToShow 'heatmap and colorbar'
fi

# 15c: Correlation heatmap between samples
echo "Generating correlation heatmap..."
multiBigwigSummary bins -b $BIGWIG_DIR/*.bw -o $PLOT_DIR/multibw_summary.npz

plotCorrelation -in $PLOT_DIR/multibw_summary.npz \
    --corMethod pearson --skipZeros \
    --plotTitle "Pearson Correlation of Read Counts" \
    --whatToPlot heatmap --colorMap RdYlBu --plotNumbers \
    -o $PLOT_DIR/correlation_heatmap.pdf \
    --outFileCorMatrix $PLOT_DIR/correlation_matrix.txt

plotCorrelation -in $PLOT_DIR/multibw_summary.npz \
    --corMethod pearson --skipZeros \
    --plotTitle "Pearson Correlation of Read Counts" \
    --whatToPlot heatmap --colorMap RdYlBu --plotNumbers \
    -o $PLOT_DIR/correlation_heatmap.png \
    --outFileCorMatrix $PLOT_DIR/correlation_matrix.txt

plotCorrelation -in $PLOT_DIR/multibw_summary.npz \
    --corMethod pearson --skipZeros \
    --plotTitle "Pearson Correlation - PCA" \
    --whatToPlot scatterplot --colorMap RdYlBu \
    -o $PLOT_DIR/PCA_plot.pdf

plotCorrelation -in $PLOT_DIR/multibw_summary.npz \
    --corMethod pearson --skipZeros \
    --plotTitle "Pearson Correlation - PCA" \
    --whatToPlot scatterplot --colorMap RdYlBu \
    -o $PLOT_DIR/PCA_plot.png

# 15d: Coverage plots
echo "Generating coverage plots..."
plotCoverage -b $DEDUP_DIR/*.dedup.bam \
    --plotFile $PLOT_DIR/coverage_plot.pdf \
    --outRawCounts $PLOT_DIR/coverage_counts.txt

plotCoverage -b $DEDUP_DIR/*.dedup.bam \
    --plotFile $PLOT_DIR/coverage_plot.png \
    --outRawCounts $PLOT_DIR/coverage_counts.txt

# 15e: Peak annotation distribution plot
echo "Generating peak annotation distribution plot..."
cat > $PLOT_DIR/plot_peak_distribution.R << 'EOF'
library(ggplot2)

# Read peak distribution summary
data <- read.table("../final_results/peak_distribution_summary.txt", header=FALSE)
colnames(data) <- c("Count", "Feature")

# Calculate percentages
data$Percentage <- (data$Count / sum(data$Count)) * 100

# Create bar plot
p1 <- ggplot(data, aes(x=reorder(Feature, Count), y=Count, fill=Feature)) +
    geom_bar(stat="identity") +
    coord_flip() +
    theme_bw() +
    labs(title="Peak Distribution Across Genomic Features", 
         x="Genomic Feature", y="Number of Peaks") +
    theme(plot.title = element_text(hjust=0.5, size=16, face="bold"),
          legend.position="none")
ggsave("peak_distribution_barplot.pdf", p1, width=10, height=6)
ggsave("peak_distribution_barplot.png", p1, width=10, height=6, dpi=300)

# Create pie chart
p2 <- ggplot(data, aes(x="", y=Percentage, fill=Feature)) +
    geom_bar(stat="identity", width=1) +
    coord_polar("y", start=0) +
    theme_void() +
    labs(title="Peak Distribution Across Genomic Features (%)") +
    theme(plot.title = element_text(hjust=0.5, size=16, face="bold")) +
    geom_text(aes(label=paste0(round(Percentage,1),"%")), 
              position=position_stack(vjust=0.5))
ggsave("peak_distribution_piechart.pdf", p2, width=10, height=8)
ggsave("peak_distribution_piechart.png", p2, width=10, height=8, dpi=300)
EOF

# 15f: QC metrics plot
echo "Generating QC metrics plot..."
cat > $PLOT_DIR/plot_qc_metrics.R << 'EOF'
library(ggplot2)
library(tidyr)
library(dplyr)

# Read summary stats
data <- read.table("../final_results/pipeline_summary_stats.tsv", header=TRUE, sep="\t")

# Remove total peaks row
data <- data %>% filter(!is.na(Sample))

# Plot mapping rate
p1 <- ggplot(data, aes(x=Sample, y=Mapping_Rate, fill=Sample)) +
    geom_bar(stat="identity") +
    theme_bw() +
    labs(title="Mapping Rate by Sample", y="Mapping Rate (%)", x="") +
    theme(plot.title = element_text(hjust=0.5, size=14, face="bold"),
          axis.text.x = element_text(angle=45, hjust=1),
          legend.position="none")
ggsave("mapping_rate.pdf", p1, width=8, height=6)
ggsave("mapping_rate.png", p1, width=8, height=6, dpi=300)

# Plot duplication rate
p2 <- ggplot(data, aes(x=Sample, y=Duplication_Rate, fill=Sample)) +
    geom_bar(stat="identity") +
    theme_bw() +
    labs(title="Duplication Rate by Sample", y="Duplication Rate (%)", x="") +
    theme(plot.title = element_text(hjust=0.5, size=14, face="bold"),
          axis.text.x = element_text(angle=45, hjust=1),
          legend.position="none")
ggsave("duplication_rate.pdf", p2, width=8, height=6)
ggsave("duplication_rate.png", p2, width=8, height=6, dpi=300)

# Plot read counts at each step
data_long <- data %>%
    select(Sample, Raw_Reads, Trimmed_Reads, Reads_After_Dedup) %>%
    gather(key="Step", value="Reads", -Sample)

data_long$Step <- factor(data_long$Step, 
                         levels=c("Raw_Reads", "Trimmed_Reads", "Reads_After_Dedup"),
                         labels=c("Raw", "Trimmed", "Final"))

p3 <- ggplot(data_long, aes(x=Sample, y=Reads, fill=Step)) +
    geom_bar(stat="identity", position="dodge") +
    theme_bw() +
    labs(title="Read Counts Through Pipeline", y="Number of Reads", x="") +
    theme(plot.title = element_text(hjust=0.5, size=14, face="bold"),
          axis.text.x = element_text(angle=45, hjust=1)) +
    scale_fill_brewer(palette="Set2")
ggsave("read_counts_progression.pdf", p3, width=10, height=6)
ggsave("read_counts_progression.png", p3, width=10, height=6, dpi=300)
EOF

# Run R scripts
cd $PLOT_DIR
if command -v Rscript &> /dev/null; then
    echo "Running R plotting scripts..."
    Rscript plot_fragment_sizes.R 2>/dev/null || echo "Fragment size plot failed (might need ggplot2)"
    Rscript plot_peak_distribution.R 2>/dev/null || echo "Peak distribution plot failed (might need ggplot2)"
    Rscript plot_qc_metrics.R 2>/dev/null || echo "QC metrics plot failed (might need ggplot2/tidyr)"
else
    echo "R not found, skipping R-based plots"
fi
cd $BASE_DIR

echo "All plots saved to $PLOT_DIR"
mark_step_complete "step15_plotting"
fi

# Step 16: Final MultiQC report generation
if is_step_complete "step16_final_multiqc"; then
    echo "Skipping Step 16: Final MultiQC (already completed)"
else
    echo "Generating final MultiQC report..."
    multiqc $FINAL_RESULTS $PEAK_DIR $BIGWIG_DIR $PLOT_DIR -o $MULTIQC_DIR --force
    mark_step_complete "step16_final_multiqc"
fi

echo "====================================="
echo "PIPELINE COMPLETED SUCCESSFULLY!"
echo "====================================="
echo "All results are in $MULTIQC_DIR"
echo "Summary statistics table: $SUMMARY_TABLE"
echo "Plots and visualizations: $PLOT_DIR"
echo "Progress log: $BASE_DIR/.pipeline_progress"
echo ""
echo "Reproducibility Information:"
echo "  Version log: $BASE_DIR/reproducibility_log.txt"
echo "  Command log: $BASE_DIR/command_log.txt"
echo "====================================="
