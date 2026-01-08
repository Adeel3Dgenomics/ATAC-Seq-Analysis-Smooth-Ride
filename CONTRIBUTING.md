# Contributing to ATAC-seq Pipeline

Thank you for your interest in contributing! This document provides guidelines for contributing to the ATAC-seq pipeline.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of background or experience level.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates.

**Good bug reports include:**

- Clear, descriptive title
- Detailed steps to reproduce
- Expected vs. actual behavior
- Error messages and logs
- System information (OS, software versions)
- Sample data (if possible)

**Template:**

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Run command '...'
2. With configuration '...'
3. See error

**Expected behavior**
What you expected to happen.

**Error messages**
```
Paste error messages here
```

**System Info**
- OS: [e.g., Ubuntu 20.04]
- Pipeline version: [e.g., 1.0.0]
- Software versions: [output of check_dependencies.sh]

**Additional context**
Any other relevant information.
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- Clear use case
- Expected behavior
- Why it would be useful
- Possible implementation approach

### Contributing Code

We welcome pull requests for:

- Bug fixes
- New features
- Performance improvements
- Documentation improvements
- Test coverage

## Getting Started

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/ATAC-seq-pipeline.git
cd ATAC-seq-pipeline

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/ATAC-seq-pipeline.git
```

### Set Up Development Environment

```bash
# Create conda environment
conda env create -f environment.yml
conda activate atac-seq

# Install Genrich
cd ~/software
git clone https://github.com/jsh58/Genrich.git
cd Genrich && make
export PATH=$PATH:~/software/Genrich
```

### Create a Branch

```bash
# Update your fork
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/my-new-feature
# or
git checkout -b fix/bug-description
```

## Development Workflow

### 1. Make Changes

- Write clear, documented code
- Follow existing code style
- Add comments for complex logic
- Update relevant documentation

### 2. Test Changes

```bash
# Run dependency checker
bash scripts/check_dependencies.sh

# Run test dataset
bash test_data/run_test.sh

# Verify outputs match expected results
```

### 3. Commit Changes

```bash
# Stage changes
git add file1.sh file2.md

# Commit with descriptive message
git commit -m "Add feature: describe what you added"
```

**Good commit messages:**
```
Add support for single-end reads

- Modified alignment step to handle single-end
- Updated configuration options
- Added documentation
- Closes #123
```

### 4. Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/my-new-feature

# Create pull request on GitHub
# Include description of changes and reference any issues
```

## Coding Standards

### Bash Scripts

**Style guidelines:**

```bash
#!/bin/bash

# Use meaningful variable names
GENOME_INDEX="/path/to/genome"  # Good
GI="/path/to/genome"            # Avoid

# Use functions for repeated code
align_reads() {
    local sample=$1
    local output=$2
    bowtie2 -x $GENOME_INDEX ... > $output
}

# Add error checking
if [ ! -f "$GENOME_FA" ]; then
    echo "Error: Genome file not found: $GENOME_FA"
    exit 1
fi

# Use consistent indentation (4 spaces)
if [ condition ]; then
    command1
    command2
fi

# Add comments for complex sections
# Calculate effective genome size for normalization
# Formula: total_bases - N_bases - blacklist_bases

# Quote variables to handle spaces
fastqc "$INPUT_FILE" -o "$OUTPUT_DIR"
```

### Documentation

**Update documentation when:**

- Adding new features
- Changing parameters
- Modifying output files
- Adding dependencies
- Changing configuration options

**Documentation files:**
- README.md - Overview and quick start
- USAGE.md - Detailed usage instructions
- INSTALL.md - Installation guide
- TROUBLESHOOTING.md - Common issues
- CHANGELOG.md - Version history

### Code Comments

```bash
# Good: Explains WHY, not WHAT
# Remove chrM to reduce mitochondrial contamination
samtools view -h file.bam | grep -v "chrM" > filtered.bam

# Avoid: States the obvious
# Filter BAM file
samtools view -h file.bam | grep -v "chrM" > filtered.bam
```

## Testing

### Manual Testing

Before submitting:

1. **Run on test data:**
   ```bash
   bash test_data/run_test.sh
   ```

2. **Verify outputs:**
   - Check all expected files are created
   - Compare metrics to test_output/
   - Verify plots are generated correctly

3. **Test edge cases:**
   - Empty input directories
   - Missing reference files
   - Interrupted pipeline (resume capability)
   - Different genome builds

### Test Checklist

- [ ] Pipeline completes without errors
- [ ] All output files generated
- [ ] QC metrics within expected range
- [ ] Plots render correctly
- [ ] Resume functionality works
- [ ] Documentation updated
- [ ] No new dependencies without reason
- [ ] Works on clean environment

## Documentation

### README Updates

Update README.md for:
- New features
- Changed workflows
- New dependencies
- Updated metrics

### USAGE Guide

Update USAGE.md for:
- New parameters
- Changed output structure
- New plots or analyses
- Advanced options

### CHANGELOG

Add entry to CHANGELOG.md:

```markdown
## [Unreleased]

### Added
- New feature description (#PR_number)

### Changed
- What was changed (#PR_number)

### Fixed
- Bug fix description (#PR_number)
```

## Submitting Changes

### Pull Request Process

1. **Before submitting:**
   - Update documentation
   - Add tests if applicable
   - Update CHANGELOG.md
   - Ensure code follows style guidelines

2. **PR Description should include:**
   - What: Description of changes
   - Why: Motivation and context
   - How: Implementation approach
   - Testing: How you tested it
   - References: Related issues

**Template:**

```markdown
## Description
Brief description of changes

## Motivation
Why is this change needed?

## Changes
- Change 1
- Change 2

## Testing
How did you test this?
- [ ] Ran test dataset
- [ ] Tested edge cases
- [ ] Updated documentation

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Tests pass
- [ ] No breaking changes (or clearly documented)

Closes #issue_number
```

### Review Process

1. Maintainers will review your PR
2. Address any requested changes
3. Once approved, PR will be merged
4. Your contribution will be credited in CHANGELOG

## Questions?

- **Documentation**: Check existing docs first
- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: [your.email@institution.edu]

## Recognition

Contributors will be:
- Listed in GitHub contributors
- Mentioned in CHANGELOG
- Credited in relevant documentation

## License

By contributing, you agree that your contributions will be licensed under the same MIT License that covers the project.

---

**Thank you for contributing to make this pipeline better!** 🎉
