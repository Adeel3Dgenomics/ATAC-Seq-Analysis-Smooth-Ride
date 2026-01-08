# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-08

### Added
- Initial release of ATAC-seq analysis pipeline
- Complete workflow from FASTQ to peaks and visualizations
- Automatic quality control with FastQC and MultiQC
- Adapter trimming with Trim Galore
- Alignment with Bowtie2
- Duplicate removal with Picard
- Peak calling with Genrich (ATAC-seq mode)
- Blacklist region filtering
- Peak annotation with HOMER
- BigWig track generation for genome browsers
- FRiP score calculation
- Comprehensive plotting suite (15+ plots)
- Resume capability for interrupted runs
- Full reproducibility logging (software versions, parameters, checksums)
- Chromosome naming compatibility auto-detection and fixing
- Detailed documentation (README, INSTALL, USAGE, TROUBLESHOOTING)
- Example test outputs for quality comparison
- SLURM cluster submission script
- Configuration template with pre-configured genome options
- Conda environment file for easy installation
- MIT License

### Features
- **Step 1**: FastQC on raw data
- **Step 2**: Adapter trimming and quality filtering
- **Step 3**: FastQC on trimmed data
- **Step 4**: MultiQC summary for QC
- **Step 5**: Bowtie2 alignment with ATAC-optimized parameters
- **Step 6**: BAM indexing
- **Step 7**: PCR duplicate removal
- **Step 7a**: Name-sorting for peak calling
- **Step 8**: MultiQC for alignment stats
- **Step 9**: Peak calling with Genrich
- **Step 10**: Blacklist filtering
- **Step 10a**: FRiP score calculation
- **Step 11**: Peak annotation (HOMER + gene overlap)
- **Step 12**: BigWig generation for visualization
- **Step 13**: Read counting in peaks (featureCounts)
- **Step 14**: Summary statistics table
- **Step 15**: Comprehensive plotting
  - Fragment size distribution
  - TSS enrichment
  - Sample correlation heatmap
  - PCA plot
  - Coverage plots
  - Peak distribution charts
  - QC metrics plots
- **Step 16**: Final MultiQC report

### Documentation
- Comprehensive README with badges and quick start
- Detailed installation guide (conda, manual, Docker)
- Complete usage guide with examples
- Troubleshooting guide for common issues
- Example test outputs with expected metrics
- Configuration template with annotations
- Changelog (this file)
- MIT License
- .gitignore for clean repository

### Configuration
- Customizable parameters via config.sh
- Pre-configured settings for hg19, hg38, mm10, mm9
- Adjustable computational resources
- Optional parameters for advanced users

### Quality Control
- Mapping rate tracking
- Duplication rate calculation
- FRiP score assessment
- TSS enrichment analysis
- Fragment size distribution
- Sample correlation analysis

### Reproducibility
- Software version logging
- Parameter documentation
- Command logging
- Input file checksums (MD5)
- Reference genome checksums
- R random seed setting
- Python hash seed setting

---

## [Unreleased]

### Planned Features
- [ ] Support for single-end reads
- [ ] Integration with differential accessibility analysis (DESeq2)
- [ ] Motif enrichment analysis (HOMER)
- [ ] Transcription factor footprinting (TOBIAS)
- [ ] Support for DNase-seq data
- [ ] Docker container for complete pipeline
- [ ] Galaxy tool wrapper
- [ ] Nextflow implementation
- [ ] Interactive quality dashboard
- [ ] Automated report generation
- [ ] Peak set comparison tools
- [ ] Integration with ChIP-seq analysis
- [ ] Support for mm39 and other recent genome builds

### Known Issues
- Genrich not available through conda (requires manual installation)
- Large dataset processing requires significant disk space (500GB+)
- R plotting may fail on headless systems without X11 forwarding
- SLURM script needs customization for different cluster configurations

### Future Improvements
- Optimize memory usage for large samples
- Add checkpoint validation
- Implement parallel sample processing option
- Add more genome pre-configurations
- Improve error messages
- Add dry-run mode
- Create web-based configuration generator

---

## Version History

### [1.0.0] - 2026-01-08
- Initial public release

---

## How to Update

To update to the latest version:

```bash
cd ATAC-seq-pipeline
git pull origin main

# Update conda environment
conda env update -f environment.yml

# Check for new dependencies
bash scripts/check_dependencies.sh
```

## Breaking Changes

None in this release.

## Migration Guide

Not applicable for initial release.

---

## Contributors

- Main Developer: [Your Name]
- Contributors: See [GitHub Contributors](https://github.com/yourusername/ATAC-seq-pipeline/graphs/contributors)

## Acknowledgments

This pipeline integrates the following tools:
- FastQC (Babraham Bioinformatics)
- Trim Galore (Felix Krueger)
- Bowtie2 (Langmead & Salzberg)
- SAMtools (Li et al.)
- Picard (Broad Institute)
- Genrich (John Gaspar)
- BEDTools (Quinlan & Hall)
- deepTools (Ramírez et al.)
- HOMER (Heinz et al.)
- Subread (Liao et al.)
- MultiQC (Ewels et al.)

See [CITATIONS.md](CITATIONS.md) for complete citations.

---

**Questions or suggestions?** [Open an issue](https://github.com/yourusername/ATAC-seq-pipeline/issues/new)
