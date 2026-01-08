# Installation Guide

This guide will help you install all dependencies required for the ATAC-seq pipeline.

## Table of Contents

- [System Requirements](#system-requirements)
- [Installation Methods](#installation-methods)
  - [Option 1: Conda (Recommended)](#option-1-conda-recommended)
  - [Option 2: Manual Installation](#option-2-manual-installation)
  - [Option 3: Docker](#option-3-docker)
- [Post-Installation](#post-installation)
- [Genome Reference Setup](#genome-reference-setup)
- [Verification](#verification)

## System Requirements

### Hardware

- **CPU**: 8+ cores (16+ recommended)
- **RAM**: 32 GB minimum (64 GB recommended)
- **Storage**: 500 GB+ free space per analysis
- **Network**: Required for downloading reference genomes

### Operating System

- Linux (Ubuntu 18.04+, CentOS 7+, or similar)
- macOS 10.14+ (some tools may have limited support)
- Windows: Use WSL2 (Windows Subsystem for Linux)

### Prerequisites

- Bash 4.0 or later
- Internet connection for installation
- sudo/root access (for system-wide installation)

## Installation Methods

### Option 1: Conda (Recommended)

Conda provides the easiest installation with automatic dependency resolution.

#### Step 1: Install Conda/Mamba

If you don't have conda installed:

```bash
# Download Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# Follow prompts and restart shell
source ~/.bashrc
```

For faster package installation, install mamba:

```bash
conda install -n base -c conda-forge mamba
```

#### Step 2: Create Environment

```bash
# Create environment from provided file
conda env create -f environment.yml

# Or create manually
conda create -n atac-seq -c bioconda -c conda-forge \
    fastqc=0.11.9 \
    trim-galore=0.6.7 \
    bowtie2=2.4.5 \
    samtools=1.15 \
    picard=2.27.4 \
    bedtools=2.30.0 \
    deeptools=3.5.1 \
    homer=4.11 \
    subread=2.0.3 \
    multiqc=1.12 \
    r-base=4.2 \
    r-ggplot2 \
    r-dplyr \
    r-tidyr
```

#### Step 3: Install Genrich

Genrich is not in conda, so install manually:

```bash
conda activate atac-seq

# Install Genrich
cd ~/software
git clone https://github.com/jsh58/Genrich.git
cd Genrich
make
sudo cp Genrich /usr/local/bin/
# Or add to PATH: export PATH=$PATH:~/software/Genrich
```

#### Step 4: Activate Environment

```bash
conda activate atac-seq
```

Add to your `.bashrc` to activate automatically:

```bash
echo "conda activate atac-seq" >> ~/.bashrc
```

---

### Option 2: Manual Installation

For users who prefer manual installation or need specific versions.

#### Step 1: Install System Dependencies

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    wget \
    git \
    unzip \
    default-jdk \
    python3 \
    python3-pip \
    r-base \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    zlib1g-dev
```

**CentOS/RHEL:**

```bash
sudo yum groupinstall -y "Development Tools"
sudo yum install -y \
    wget \
    git \
    unzip \
    java-1.8.0-openjdk \
    python3 \
    python3-pip \
    R \
    bzip2-devel \
    xz-devel \
    libcurl-devel \
    zlib-devel
```

#### Step 2: Install Bioinformatics Tools

Create a software directory:

```bash
mkdir -p ~/software
cd ~/software
```

**FastQC:**

```bash
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip
unzip fastqc_v0.11.9.zip
chmod +x FastQC/fastqc
sudo ln -s ~/software/FastQC/fastqc /usr/local/bin/fastqc
```

**Trim Galore:**

```bash
wget https://github.com/FelixKrueger/TrimGalore/archive/0.6.7.tar.gz
tar xzf 0.6.7.tar.gz
sudo ln -s ~/software/TrimGalore-0.6.7/trim_galore /usr/local/bin/trim_galore

# Also need cutadapt
pip3 install --user cutadapt
```

**Bowtie2:**

```bash
wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.5/bowtie2-2.4.5-linux-x86_64.zip
unzip bowtie2-2.4.5-linux-x86_64.zip
sudo cp bowtie2-2.4.5-linux-x86_64/bowtie2* /usr/local/bin/
```

**SAMtools:**

```bash
wget https://github.com/samtools/samtools/releases/download/1.15/samtools-1.15.tar.bz2
tar xjf samtools-1.15.tar.bz2
cd samtools-1.15
./configure --prefix=/usr/local
make
sudo make install
cd ..
```

**Picard:**

```bash
wget https://github.com/broadinstitute/picard/releases/download/2.27.4/picard.jar
sudo mkdir -p /opt/picard
sudo mv picard.jar /opt/picard/
echo 'alias picard="java -jar /opt/picard/picard.jar"' >> ~/.bashrc
```

**BEDTools:**

```bash
wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz
tar xzf bedtools-2.30.0.tar.gz
cd bedtools2
make
sudo make install
cd ..
```

**Genrich:**

```bash
git clone https://github.com/jsh58/Genrich.git
cd Genrich
make
sudo cp Genrich /usr/local/bin/
cd ..
```

**deepTools:**

```bash
pip3 install --user deeptools
```

**HOMER:**

```bash
mkdir homer
cd homer
wget http://homer.ucsd.edu/homer/configureHomer.pl
perl configureHomer.pl -install
echo 'export PATH=$PATH:~/software/homer/bin' >> ~/.bashrc
cd ..
```

**Subread (for featureCounts):**

```bash
wget https://sourceforge.net/projects/subread/files/subread-2.0.3/subread-2.0.3-Linux-x86_64.tar.gz
tar xzf subread-2.0.3-Linux-x86_64.tar.gz
sudo cp subread-2.0.3-Linux-x86_64/bin/* /usr/local/bin/
```

**MultiQC:**

```bash
pip3 install --user multiqc
```

#### Step 3: Install R Packages

```bash
R --vanilla <<EOF
install.packages(c("ggplot2", "dplyr", "tidyr"), 
                 repos="https://cloud.r-project.org")
q()
EOF
```

#### Step 4: Update PATH

```bash
source ~/.bashrc
```

---

### Option 3: Docker

For containerized, reproducible environment.

#### Step 1: Install Docker

```bash
# Ubuntu
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

Log out and back in for group changes to take effect.

#### Step 2: Build Docker Image

```bash
cd ATAC-seq-pipeline
docker build -t atac-seq:latest .
```

#### Step 3: Run Pipeline in Container

```bash
docker run -v /path/to/data:/data atac-seq:latest bash ATAC_main.sh
```

---

## Post-Installation

### Verify Installation

Run the verification script:

```bash
bash scripts/check_dependencies.sh
```

Expected output:

```
Checking dependencies...
✓ fastqc found (v0.11.9)
✓ trim_galore found (v0.6.7)
✓ bowtie2 found (v2.4.5)
✓ samtools found (v1.15)
✓ picard found (v2.27.4)
✓ bedtools found (v2.30.0)
✓ Genrich found (v0.6)
✓ deepTools found (v3.5.1)
✓ HOMER found (v4.11)
✓ featureCounts found (v2.0.3)
✓ multiqc found (v1.12)
✓ R found (v4.2.0)
✓ All R packages installed

All dependencies satisfied!
```

### Manual Verification

Check each tool individually:

```bash
fastqc --version
trim_galore --version
bowtie2 --version
samtools --version
picard MarkDuplicates --version
bedtools --version
Genrich -h
bamCoverage --version
annotatePeaks.pl
featureCounts -v
multiqc --version
R --version
```

## Genome Reference Setup

### Download Human Genome (hg19)

```bash
# Create reference directory
mkdir -p ~/references/hg19
cd ~/references/hg19

# Download genome FASTA
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
gunzip hg19.fa.gz

# Build Bowtie2 index
mkdir -p bowtie2_index
bowtie2-build hg19.fa bowtie2_index/hg19

# Download blacklist regions
wget https://github.com/Boyle-Lab/Blacklist/raw/master/lists/hg19-blacklist.v2.bed.gz
gunzip hg19-blacklist.v2.bed.gz
mv hg19-blacklist.v2.bed hg19-blacklist.bed

# Download gene annotations
mkdir -p Annotation/Genes
cd Annotation/Genes

# RefSeq genes
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz
gunzip refGene.txt.gz

# Convert to BED format
awk 'BEGIN{OFS="\t"} {print $3,$5,$6,$2,$13,$4}' refGene.txt > genes.bed

# GTF format (if needed)
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/genes/hg19.refGene.gtf.gz
gunzip hg19.refGene.gtf.gz
mv hg19.refGene.gtf genes.gtf
```

### Download Mouse Genome (mm10)

```bash
mkdir -p ~/references/mm10
cd ~/references/mm10

wget http://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/mm10.fa.gz
gunzip mm10.fa.gz

mkdir -p bowtie2_index
bowtie2-build mm10.fa bowtie2_index/mm10

wget https://github.com/Boyle-Lab/Blacklist/raw/master/lists/mm10-blacklist.v2.bed.gz
gunzip mm10-blacklist.v2.bed.gz
mv mm10-blacklist.v2.bed mm10-blacklist.bed
```

### Other Genomes

For other genomes, download from:
- **UCSC Genome Browser**: http://hgdownload.soe.ucsc.edu/downloads.html
- **ENSEMBL**: http://ftp.ensembl.org/pub/
- **NCBI**: https://www.ncbi.nlm.nih.gov/genome/

## Storage Configuration

Ensure adequate storage space:

```bash
# Check available space
df -h

# Recommended partition sizes:
# /home or /data: 500GB+ (for analysis output)
# /tmp: 100GB+ (for temporary files)
```

Configure temporary directory (optional):

```bash
export TMPDIR=/path/to/large/tmp
echo 'export TMPDIR=/path/to/large/tmp' >> ~/.bashrc
```

## Cluster Configuration (Optional)

For SLURM clusters, ensure modules are available:

```bash
module avail  # Check available modules

# Load required modules (example)
module load fastqc/0.11.9
module load bowtie2/2.4.5
module load samtools/1.15
# etc.
```

Add to your submit script or `.bashrc`.

## Troubleshooting Installation

### Common Issues

**Issue: "Command not found" after installation**

Solution: Update PATH

```bash
export PATH=$PATH:/path/to/tool/bin
source ~/.bashrc
```

**Issue: "Permission denied"**

Solution: Use sudo or install to user directory

```bash
# For pip packages
pip3 install --user package_name

# For conda
conda install --prefix ~/.conda package_name
```

**Issue: Java version conflicts (Picard)**

Solution: Specify Java version

```bash
# Install specific Java version
sudo apt-get install openjdk-11-jdk

# Set Java version
sudo update-alternatives --config java
```

**Issue: R package installation fails**

Solution: Install system dependencies

```bash
# Ubuntu
sudo apt-get install -y libxml2-dev libssl-dev libcurl4-openssl-dev

# Then retry R package installation
```

**Issue: Out of disk space during installation**

Solution: Clean package caches

```bash
# Conda
conda clean --all

# APT
sudo apt-get clean

# Pip
pip3 cache purge
```

### Getting Help

If you encounter issues:

1. Check the [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide
2. Search [GitHub Issues](https://github.com/yourusername/ATAC-seq-pipeline/issues)
3. Post a new issue with:
   - Output of `bash scripts/check_dependencies.sh`
   - Your OS and version
   - Error messages
   - Installation method used

## Next Steps

After successful installation:

1. ✅ Verify all dependencies: `bash scripts/check_dependencies.sh`
2. ✅ Download reference genome (see above)
3. ✅ Configure pipeline: `cp config.example.sh config.sh`
4. ✅ Run test data: `bash test_data/run_test.sh`
5. ✅ Read [USAGE.md](USAGE.md) for detailed usage

---

**Installation complete!** You're ready to run the ATAC-seq pipeline.
