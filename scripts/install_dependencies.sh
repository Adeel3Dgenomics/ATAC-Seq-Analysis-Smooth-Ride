#!/bin/bash

# Automated Installer for ATAC-seq Pipeline Dependencies
# This script installs all required tools using conda/mamba

set -e  # Exit on error

echo "=========================================="
echo "ATAC-seq Pipeline Automated Installer"
echo "=========================================="
echo ""

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "Error: Conda is not installed."
    echo ""
    echo "Please install Miniconda or Anaconda first:"
    echo "  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    echo "  bash Miniconda3-latest-Linux-x86_64.sh"
    echo ""
    exit 1
fi

echo "✓ Conda found: $(conda --version)"
echo ""

# Check if mamba is available (faster than conda)
if command -v mamba &> /dev/null; then
    INSTALLER="mamba"
    echo "✓ Using mamba for faster installation"
else
    INSTALLER="conda"
    echo "Using conda for installation (consider installing mamba for speed)"
    echo "  conda install -n base -c conda-forge mamba"
fi
echo ""

# Ask user for environment name
read -p "Enter environment name [atac-seq]: " ENV_NAME
ENV_NAME=${ENV_NAME:-atac-seq}

# Check if environment already exists
if conda env list | grep -q "^$ENV_NAME "; then
    echo ""
    echo "Warning: Environment '$ENV_NAME' already exists."
    read -p "Do you want to remove and recreate it? (y/N): " RECREATE
    if [[ $RECREATE =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        conda env remove -n $ENV_NAME -y
    else
        echo "Updating existing environment..."
    fi
fi

echo ""
echo "Creating/updating conda environment: $ENV_NAME"
echo "This may take 10-20 minutes..."
echo ""

# Create environment if it doesn't exist
if ! conda env list | grep -q "^$ENV_NAME "; then
    $INSTALLER create -n $ENV_NAME python=3.9 -y
fi

# Activate environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate $ENV_NAME

echo ""
echo "Installing bioinformatics tools..."
echo ""

# Install from bioconda
$INSTALLER install -y -c bioconda -c conda-forge \
    fastqc=0.11.9 \
    trim-galore=0.6.7 \
    cutadapt=4.1 \
    bowtie2=2.4.5 \
    samtools=1.15 \
    picard=2.27.4 \
    bedtools=2.30.0 \
    deeptools=3.5.1 \
    homer=4.11 \
    subread=2.0.3 \
    multiqc=1.12

echo ""
echo "Installing R packages..."
echo ""

$INSTALLER install -y -c conda-forge \
    r-base=4.2 \
    r-ggplot2=3.3.6 \
    r-dplyr=1.0.9 \
    r-tidyr=1.2.0

echo ""
echo "Installing utilities..."
echo ""

$INSTALLER install -y -c conda-forge \
    wget curl git bc

echo ""
echo "=========================================="
echo "Installing Genrich (not available in conda)"
echo "=========================================="
echo ""

# Create software directory
SOFT_DIR="$HOME/software"
mkdir -p $SOFT_DIR
cd $SOFT_DIR

# Check if Genrich is already installed
if command -v Genrich &> /dev/null; then
    echo "✓ Genrich already installed"
else
    echo "Installing Genrich from GitHub..."
    
    if [ -d "Genrich" ]; then
        echo "Removing old Genrich directory..."
        rm -rf Genrich
    fi
    
    git clone https://github.com/jsh58/Genrich.git
    cd Genrich
    make
    
    # Add to conda environment bin
    CONDA_BIN=$(conda info --base)/envs/$ENV_NAME/bin
    cp Genrich $CONDA_BIN/
    chmod +x $CONDA_BIN/Genrich
    
    echo "✓ Genrich installed successfully"
fi

cd ~

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "To use the pipeline, activate the environment:"
echo "  conda activate $ENV_NAME"
echo ""
echo "Add to your .bashrc to activate automatically:"
echo "  echo 'conda activate $ENV_NAME' >> ~/.bashrc"
echo ""
echo "Verify installation:"
echo "  bash scripts/check_dependencies.sh"
echo ""
echo "Next steps:"
echo "  1. Download reference genome (see INSTALL.md)"
echo "  2. Configure pipeline (cp config.example.sh config.sh)"
echo "  3. Run test data (bash test_data/run_test.sh)"
echo "  4. Read USAGE.md for detailed instructions"
echo ""
