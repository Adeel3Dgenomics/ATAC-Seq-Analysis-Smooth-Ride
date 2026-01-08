# Troubleshooting Guide

Common issues and solutions for the ATAC-seq pipeline.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Configuration Issues](#configuration-issues)
- [Pipeline Execution Issues](#pipeline-execution-issues)
- [Data Quality Issues](#data-quality-issues)
- [Resource Issues](#resource-issues)
- [Output Issues](#output-issues)
- [Getting Help](#getting-help)

---

## Installation Issues

### Issue: "Command not found" errors

**Symptoms:**
```
bash: fastqc: command not found
bash: bowtie2: command not found
```

**Solutions:**

1. **Check if tool is installed:**
   ```bash
   which fastqc
   which bowtie2
   ```

2. **Add to PATH:**
   ```bash
   export PATH=$PATH:/path/to/tool/bin
   echo 'export PATH=$PATH:/path/to/tool/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Reinstall using conda:**
   ```bash
   conda activate atac-seq
   conda install -c bioconda fastqc bowtie2
   ```

4. **Check conda environment:**
   ```bash
   conda activate atac-seq
   which fastqc  # Should show path in conda env
   ```

### Issue: Conda environment not activating

**Symptoms:**
```
CondaError: Run 'conda init' before 'conda activate'
```

**Solution:**
```bash
conda init bash
source ~/.bashrc
conda activate atac-seq
```

### Issue: R package installation fails

**Symptoms:**
```
Error in install.packages: installation of package 'ggplot2' had non-zero exit status
```

**Solutions:**

1. **Install system dependencies (Ubuntu/Debian):**
   ```bash
   sudo apt-get install -y libxml2-dev libssl-dev libcurl4-openssl-dev libfontconfig1-dev
   ```

2. **Install via conda instead:**
   ```bash
   conda install -c conda-forge r-ggplot2 r-dplyr r-tidyr
   ```

3. **Install to local library:**
   ```R
   local_lib <- "~/R_libs"
   dir.create(local_lib, recursive=TRUE)
   .libPaths(c(local_lib, .libPaths()))
   install.packages("ggplot2", lib=local_lib)
   ```

### Issue: Genrich not found

**Symptoms:**
```
Genrich: command not found
```

**Solution:**

Genrich is not in conda, install manually:
```bash
cd ~/software
git clone https://github.com/jsh58/Genrich.git
cd Genrich
make
sudo cp Genrich /usr/local/bin/
# Or add to PATH
export PATH=$PATH:~/software/Genrich
```

Verify installation:
```bash
Genrich -h
```

### Issue: Java version conflicts (Picard)

**Symptoms:**
```
Error: A JNI error has occurred
Unsupported class file major version
```

**Solution:**

Install correct Java version:
```bash
# Check Java version
java -version

# Install Java 11 (recommended for Picard)
sudo apt-get install openjdk-11-jdk

# Set as default
sudo update-alternatives --config java
```

---

## Configuration Issues

### Issue: Cannot find reference genome files

**Symptoms:**
```
Error: Reference genome not found
bowtie2-build: No such file or directory
```

**Solutions:**

1. **Check file paths:**
   ```bash
   ls -l /path/to/genome/hg19.fa
   ls -l /path/to/bowtie2_index/hg19.1.bt2
   ```

2. **Build Bowtie2 index if missing:**
   ```bash
   mkdir -p ~/refs/hg19/bowtie2_index
   cd ~/refs/hg19/bowtie2_index
   bowtie2-build ../hg19.fa hg19
   ```

3. **Download reference genome:**
   ```bash
   cd ~/refs/hg19
   wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
   gunzip hg19.fa.gz
   ```

4. **Update config.sh with correct paths:**
   ```bash
   GENOME_INDEX="/full/path/to/bowtie2_index/hg19"
   GENOME_FA="/full/path/to/hg19.fa"
   ```

### Issue: Blacklist file not found

**Symptoms:**
```
Error: Can't open blacklist file
```

**Solution:**

Download blacklist file:
```bash
cd ~/refs/hg19
wget https://github.com/Boyle-Lab/Blacklist/raw/master/lists/hg19-blacklist.v2.bed.gz
gunzip hg19-blacklist.v2.bed.gz

# Update config.sh
BLACKLIST="/full/path/to/hg19-blacklist.v2.bed"
```

### Issue: Permission denied when writing output

**Symptoms:**
```
mkdir: cannot create directory: Permission denied
```

**Solutions:**

1. **Check directory permissions:**
   ```bash
   ls -ld /path/to/output
   ```

2. **Create directory with proper permissions:**
   ```bash
   mkdir -p ~/my_atac_analysis
   chmod 755 ~/my_atac_analysis
   ```

3. **Use directory you have write access to:**
   ```bash
   BASE_DIR="$HOME/ATAC_analysis"  # Use home directory
   ```

---

## Pipeline Execution Issues

### Issue: Pipeline stops without error message

**Symptoms:**
- Pipeline exits silently
- No error message displayed

**Solutions:**

1. **Check disk space:**
   ```bash
   df -h
   # Need at least 500GB free
   ```

2. **Check memory usage:**
   ```bash
   free -h
   top
   # Ensure sufficient RAM (32GB+ recommended)
   ```

3. **Check progress log:**
   ```bash
   cat .pipeline_progress
   tail -100 command_log.txt
   ```

4. **Run with verbose output:**
   ```bash
   bash -x ATAC_main.sh 2>&1 | tee pipeline_debug.log
   ```

### Issue: "Out of memory" errors

**Symptoms:**
```
malloc: Cannot allocate memory
Killed
```

**Solutions:**

1. **Reduce thread count:**
   ```bash
   # In config.sh
   THREADS=4  # Reduce from 8
   ```

2. **Reduce samtools sort memory:**
   ```bash
   # In ATAC_main.sh
   samtools sort -m 2G ...  # Limit memory per thread
   ```

3. **Process samples one at a time:**
   ```bash
   # Modify loop to process sequentially
   for sample in Sample1 Sample2; do
       # Process one sample completely before next
   done
   ```

4. **Use swap space:**
   ```bash
   # Create swap file (Ubuntu)
   sudo fallocate -l 32G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

### Issue: Bowtie2 alignment fails

**Symptoms:**
```
Error: Could not locate a Bowtie index
(ERR): bowtie2-align exited with value 1
```

**Solutions:**

1. **Verify index files exist:**
   ```bash
   ls -l /path/to/bowtie2_index/hg19*.bt2
   # Should see: hg19.1.bt2, hg19.2.bt2, hg19.3.bt2, hg19.4.bt2, etc.
   ```

2. **Rebuild index:**
   ```bash
   bowtie2-build hg19.fa hg19
   ```

3. **Check index path in config:**
   ```bash
   # Should NOT include .bt2 extension
   GENOME_INDEX="/path/to/hg19"  # Correct
   GENOME_INDEX="/path/to/hg19.1.bt2"  # Wrong!
   ```

### Issue: Genrich peak calling fails

**Symptoms:**
```
Error in Genrich: cannot open file
Error: no peaks found
```

**Solutions:**

1. **Check BAM files are name-sorted:**
   ```bash
   samtools view -H alignment/dedup/Sample1.qnamesort.bam | grep "SO:queryname"
   ```

2. **Verify BAM files exist:**
   ```bash
   ls -lh alignment/dedup/*.qnamesort.bam
   ```

3. **Check for empty BAM files:**
   ```bash
   samtools view -c alignment/dedup/Sample1.qnamesort.bam
   # Should show >0 reads
   ```

4. **Run Genrich manually for debugging:**
   ```bash
   Genrich -t alignment/dedup/Sample1.qnamesort.bam \
           -o test_peaks.narrowPeak \
           -j -r -v -e chrM
   ```

### Issue: MultiQC fails or produces empty report

**Symptoms:**
```
Error: No analysis results found
MultiQC report is empty
```

**Solutions:**

1. **Check that QC files exist:**
   ```bash
   ls -R QC/
   ls alignment/dedup/*_metrics.txt
   ```

2. **Run MultiQC manually:**
   ```bash
   multiqc QC/ alignment/ dedup/ -o multiqc_report/ -f -v
   ```

3. **Update MultiQC:**
   ```bash
   pip install --upgrade multiqc
   ```

---

## Data Quality Issues

### Issue: Low mapping rate (<85%)

**Possible Causes:**
- Wrong reference genome
- Adapter contamination
- Poor quality reads
- Contamination from other species

**Solutions:**

1. **Check FastQC for adapter contamination:**
   ```bash
   # View raw FastQC reports
   firefox QC/raw/*_fastqc.html
   ```

2. **Verify correct genome:**
   ```bash
   # Check chromosome names match
   samtools view -H alignment/Sample1.sorted.bam | grep "@SQ"
   grep ">" $GENOME_FA | head
   ```

3. **Check for contamination:**
   ```bash
   # Align to multiple genomes and check mapping rates
   bowtie2 -x hg19 ... # Human
   bowtie2 -x mm10 ... # Mouse
   bowtie2 -x ecoli ... # E. coli contamination
   ```

4. **More aggressive trimming:**
   ```bash
   # In ATAC_main.sh, add quality threshold
   trim_galore --quality 25 --stringency 3 ...
   ```

### Issue: High duplication rate (>40%)

**Possible Causes:**
- Over-amplification during library prep
- Low library complexity
- Too few cells used

**Solutions:**

1. **Check Picard metrics:**
   ```bash
   cat alignment/dedup/Sample1_dup_metrics.txt
   ```

2. **Assess library complexity:**
   ```bash
   # Estimate library size
   picard EstimateLibraryComplexity I=alignment/Sample1.sorted.bam O=complexity.txt
   ```

3. **For future experiments:**
   - Use more cells (50K-500K recommended)
   - Reduce PCR cycles
   - Optimize transposition conditions

4. **Note:** Some duplication is normal in ATAC-seq (20-30%)

### Issue: Low FRiP score (<0.2)

**Possible Causes:**
- Failed ATAC-seq experiment
- Poor nuclear prep
- High mitochondrial contamination
- Low sequencing depth

**Solutions:**

1. **Check mitochondrial read percentage:**
   ```bash
   total=$(samtools view -c alignment/Sample1.sorted.bam)
   mito=$(samtools view -c alignment/Sample1.sorted.bam chrM)
   echo "scale=2; $mito * 100 / $total" | bc
   # Should be <10%, ideally <5%
   ```

2. **Check number of peaks:**
   ```bash
   wc -l blacklist_removed/ATAC_peaks.filtered.narrowPeak
   # Should be >20,000
   ```

3. **Visualize in IGV:**
   ```bash
   # Load BigWig files and check signal at known accessible regions
   # e.g., Promoters of housekeeping genes
   ```

4. **Try different peak caller:**
   ```bash
   # Try MACS2 instead of Genrich
   macs2 callpeak -t alignment/dedup/Sample1.dedup.bam \
                  -f BAMPE -g hs -n test --outdir test_peaks/
   ```

### Issue: Few or no peaks called (<10,000)

**Possible Causes:**
- Low sequencing depth
- Failed experiment
- Too stringent peak calling
- Library quality issues

**Solutions:**

1. **Check read depth:**
   ```bash
   samtools view -c -F 4 alignment/dedup/Sample1.dedup.bam
   # Need >20 million reads minimum
   ```

2. **Relax peak calling stringency:**
   ```bash
   # In ATAC_main.sh, change q-value
   Genrich ... -q 0.1  # Less stringent (default 0.05)
   ```

3. **Pool replicates for peak calling:**
   ```bash
   # Merge BAM files
   samtools merge pooled.bam Sample1.bam Sample2.bam Sample3.bam
   # Call peaks on merged file
   ```

4. **Check signal distribution:**
   ```bash
   plotFingerprint -b alignment/dedup/*.dedup.bam \
                   -plot fingerprint.pdf
   ```

### Issue: Poor TSS enrichment (<5)

**Possible Causes:**
- Failed ATAC-seq
- Degraded DNA
- Improper tagmentation

**Solutions:**

1. **Check fragment size distribution:**
   ```bash
   # Should see nucleosome-free peak at ~50-100bp
   # View plots/fragment_size_distribution.pdf
   ```

2. **Verify annotation file:**
   ```bash
   head $ANNOTATION_DIR/genes.bed
   # Check TSS coordinates are correct
   ```

3. **For future experiments:**
   - Optimize transposition reaction
   - Use fresh reagents
   - Check cell viability before ATAC

---

## Resource Issues

### Issue: Disk space full

**Symptoms:**
```
No space left on device
```

**Solutions:**

1. **Check disk usage:**
   ```bash
   df -h
   du -sh *
   ```

2. **Remove intermediate files:**
   ```bash
   # After successful completion
   rm -rf trimmed_data/*.fq.gz
   rm -rf alignment/*.sorted.bam  # Keep dedup only
   rm -rf alignment/dedup/*.qnamesort.bam  # After peak calling
   ```

3. **Compress files:**
   ```bash
   gzip final_results/*.txt
   gzip plots/*.bed
   ```

4. **Use different output directory:**
   ```bash
   # In config.sh, point to larger partition
   BASE_DIR="/data/large_partition/ATAC_analysis"
   ```

### Issue: Too many open files

**Symptoms:**
```
Error: Too many open files
```

**Solution:**

Increase file limit:
```bash
ulimit -n 4096
echo "* soft nofile 4096" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 8192" | sudo tee -a /etc/security/limits.conf
```

### Issue: SLURM job timeout

**Symptoms:**
```
CANCELLED AT <time> DUE TO TIME LIMIT
```

**Solution:**

Increase time limit in submit_ATAC.sh:
```bash
#SBATCH --time=96:00:00  # Increase to 96 hours
```

---

## Output Issues

### Issue: Plots not generated

**Symptoms:**
- Missing PDF/PNG files in plots/
- R script errors

**Solutions:**

1. **Check R installation:**
   ```bash
   R --version
   Rscript --version
   ```

2. **Install R packages manually:**
   ```R
   install.packages(c("ggplot2", "dplyr", "tidyr"))
   ```

3. **Check for R errors:**
   ```bash
   cd plots/
   Rscript plot_fragment_sizes.R
   # Check error messages
   ```

4. **Install system dependencies:**
   ```bash
   # Ubuntu
   sudo apt-get install -y libcairo2-dev libxt-dev
   ```

### Issue: BigWig files empty or not generated

**Symptoms:**
- Zero-byte .bw files
- deepTools errors

**Solutions:**

1. **Check BAM file:**
   ```bash
   samtools view -c alignment/dedup/Sample1.dedup.bam
   # Should be >0
   ```

2. **Run bamCoverage manually:**
   ```bash
   bamCoverage --bam alignment/dedup/Sample1.dedup.bam \
               -o test.bw \
               --normalizeUsing RPGC \
               --effectiveGenomeSize 3137144693 \
               --binSize 10
   ```

3. **Check chromosome naming:**
   ```bash
   # Chromosomes in BAM
   samtools idxstats alignment/dedup/Sample1.dedup.bam | cut -f1
   
   # Should match genome (chr1 vs 1)
   ```

### Issue: Resume not working

**Symptoms:**
- Pipeline restarts from beginning despite .pipeline_progress file

**Solutions:**

1. **Check progress file:**
   ```bash
   cat .pipeline_progress
   ```

2. **Verify step names match:**
   ```bash
   grep "step1_fastqc_raw" .pipeline_progress
   # Should match exactly in ATAC_main.sh
   ```

3. **Force restart if needed:**
   ```bash
   rm .pipeline_progress
   bash ATAC_main.sh
   ```

---

## Getting Help

If you can't resolve your issue:

### 1. Gather Information

```bash
# Run dependency check
bash scripts/check_dependencies.sh > dependency_report.txt

# System information
uname -a
cat /etc/os-release

# Error logs
tail -100 command_log.txt > error_log.txt
```

### 2. Check Existing Issues

Search [GitHub Issues](https://github.com/yourusername/ATAC-seq-pipeline/issues)

### 3. Post New Issue

Include:
- Output of `check_dependencies.sh`
- Your OS and version
- Full error message
- Steps to reproduce
- What you've already tried

### 4. Community Support

- [GitHub Discussions](https://github.com/yourusername/ATAC-seq-pipeline/discussions)
- [Bioinformatics Stack Exchange](https://bioinformatics.stackexchange.com/)

### 5. Email Support

Email: your.email@institution.edu

**Include:**
- Subject: "ATAC-seq Pipeline Issue: [brief description]"
- All information from step 1
- Attach relevant log files

---

## Additional Resources

- [ATAC-seq Forum](https://www.biostars.org/t/ATAC-seq/)
- [Encode ATAC-seq Guidelines](https://www.encodeproject.org/atac-seq/)
- [Buenrostro et al. 2013 Protocol](https://www.nature.com/articles/nmeth.2688)

---

**Most issues can be resolved by:**
1. ✅ Checking file paths in config.sh
2. ✅ Verifying all dependencies are installed
3. ✅ Ensuring sufficient disk space and memory
4. ✅ Reading error messages carefully
5. ✅ Checking the command_log.txt file
