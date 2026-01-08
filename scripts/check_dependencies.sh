#!/bin/bash

# Dependency Checker Script for ATAC-seq Pipeline
# This script verifies that all required software is installed and accessible

echo "======================================"
echo "ATAC-seq Pipeline Dependency Checker"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
FOUND=0
MISSING=0

# Function to check if command exists
check_command() {
    local cmd=$1
    local name=$2
    local version_flag=$3
    
    if command -v $cmd &> /dev/null; then
        version=$($cmd $version_flag 2>&1 | head -1 | tr -d '\n')
        echo -e "${GREEN}✓${NC} $name found: $version"
        ((FOUND++))
        return 0
    else
        echo -e "${RED}✗${NC} $name NOT FOUND"
        ((MISSING++))
        return 1
    fi
}

# Function to check R package
check_r_package() {
    local pkg=$1
    
    if R --vanilla --quiet --slave -e "if(!requireNamespace('$pkg', quietly=TRUE)) quit(status=1)" 2>/dev/null; then
        version=$(R --vanilla --quiet --slave -e "cat(as.character(packageVersion('$pkg')))" 2>/dev/null)
        echo -e "${GREEN}✓${NC} R package $pkg found (v$version)"
        ((FOUND++))
        return 0
    else
        echo -e "${RED}✗${NC} R package $pkg NOT FOUND"
        ((MISSING++))
        return 1
    fi
}

echo "Checking core bioinformatics tools..."
echo "--------------------------------------"

check_command "fastqc" "FastQC" "--version"
check_command "trim_galore" "Trim Galore" "--version"
check_command "cutadapt" "Cutadapt" "--version"
check_command "bowtie2" "Bowtie2" "--version"
check_command "samtools" "SAMtools" "--version"
check_command "bedtools" "BEDTools" "--version"
check_command "multiqc" "MultiQC" "--version"
check_command "featureCounts" "featureCounts" "-v"
check_command "Genrich" "Genrich" "-h"

# Check Picard (special case - it's a JAR file)
if command -v picard &> /dev/null; then
    version=$(picard MarkDuplicates --version 2>&1 | head -1)
    echo -e "${GREEN}✓${NC} Picard found: $version"
    ((FOUND++))
else
    echo -e "${RED}✗${NC} Picard NOT FOUND"
    ((MISSING++))
fi

# Check deepTools
if command -v bamCoverage &> /dev/null; then
    version=$(bamCoverage --version 2>&1)
    echo -e "${GREEN}✓${NC} deepTools found: $version"
    ((FOUND++))
else
    echo -e "${RED}✗${NC} deepTools NOT FOUND"
    ((MISSING++))
fi

# Check HOMER
if command -v annotatePeaks.pl &> /dev/null; then
    homer_version=$(annotatePeaks.pl 2>&1 | grep -i version | head -1 || echo "version unknown")
    echo -e "${GREEN}✓${NC} HOMER found: $homer_version"
    ((FOUND++))
else
    echo -e "${RED}✗${NC} HOMER NOT FOUND"
    ((MISSING++))
fi

echo ""
echo "Checking R and R packages..."
echo "--------------------------------------"

check_command "R" "R" "--version"
check_command "Rscript" "Rscript" "--version"

if command -v R &> /dev/null; then
    check_r_package "ggplot2"
    check_r_package "dplyr"
    check_r_package "tidyr"
fi

echo ""
echo "Checking system utilities..."
echo "--------------------------------------"

check_command "bash" "Bash" "--version"
check_command "wget" "wget" "--version"
check_command "git" "git" "--version"
check_command "bc" "bc" "--version"

echo ""
echo "======================================"
echo "Summary"
echo "======================================"
echo -e "Dependencies found: ${GREEN}$FOUND${NC}"
echo -e "Dependencies missing: ${RED}$MISSING${NC}"
echo ""

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}✓ All dependencies are satisfied!${NC}"
    echo "You're ready to run the ATAC-seq pipeline."
    exit 0
else
    echo -e "${YELLOW}⚠ Some dependencies are missing.${NC}"
    echo ""
    echo "Installation instructions:"
    echo "  - See INSTALL.md for detailed installation guide"
    echo "  - Quick install with conda: conda env create -f environment.yml"
    echo "  - Manual installation: see INSTALL.md Option 2"
    echo ""
    exit 1
fi
