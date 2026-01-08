# Citations

If you use this pipeline, please cite the following tools and methods:

## ATAC-seq Method

**Primary Citation:**
```
Buenrostro, J.D., Giresi, P.G., Zaba, L.C., Chang, H.Y., & Greenleaf, W.J. (2013).
Transposition of native chromatin for fast and sensitive epigenomic profiling of 
open chromatin, DNA-binding proteins and nucleosome position.
Nature Methods, 10(12), 1213-1218.
doi: 10.1038/nmeth.2688
```

## Software Tools

### FastQC
```
Andrews, S. (2010). FastQC: A Quality Control Tool for High Throughput Sequence Data.
Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc
```

### Trim Galore
```
Krueger, F. (2015). Trim Galore: A Wrapper Tool Around Cutadapt and FastQC.
Available online at: http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/
```

### Cutadapt
```
Martin, M. (2011). Cutadapt removes adapter sequences from high-throughput sequencing reads.
EMBnet.journal, 17(1), 10-12.
doi: 10.14806/ej.17.1.200
```

### Bowtie2
```
Langmead, B., & Salzberg, S.L. (2012). Fast gapped-read alignment with Bowtie 2.
Nature Methods, 9(4), 357-359.
doi: 10.1038/nmeth.1923
```

### SAMtools
```
Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., ... & 1000 Genome 
Project Data Processing Subgroup. (2009). The Sequence Alignment/Map format and SAMtools.
Bioinformatics, 25(16), 2078-2079.
doi: 10.1093/bioinformatics/btp352
```

### Picard
```
Broad Institute (2019). Picard Toolkit.
Available online at: http://broadinstitute.github.io/picard/
```

### Genrich
```
Gaspar, J.M. (2018). Genrich: Detecting sites of genomic enrichment.
Available online at: https://github.com/jsh58/Genrich
```

### BEDTools
```
Quinlan, A.R., & Hall, I.M. (2010). BEDTools: a flexible suite of utilities for comparing 
genomic features.
Bioinformatics, 26(6), 841-842.
doi: 10.1093/bioinformatics/btq033
```

### deepTools
```
Ramírez, F., Ryan, D.P., Grüning, B., Bhardwaj, V., Kilpert, F., Richter, A.S., ... & 
Manke, T. (2016). deepTools2: a next generation web server for deep-sequencing data analysis.
Nucleic Acids Research, 44(W1), W160-W165.
doi: 10.1093/nar/gkw257
```

### HOMER
```
Heinz, S., Benner, C., Spann, N., Bertolino, E., Lin, Y.C., Laslo, P., ... & Glass, C.K. (2010).
Simple combinations of lineage-determining transcription factors prime cis-regulatory elements 
required for macrophage and B cell identities.
Molecular Cell, 38(4), 576-589.
doi: 10.1016/j.molcel.2010.05.004
```

### Subread (featureCounts)
```
Liao, Y., Smyth, G.K., & Shi, W. (2014). featureCounts: an efficient general purpose program 
for assigning sequence reads to genomic features.
Bioinformatics, 30(7), 923-930.
doi: 10.1093/bioinformatics/btt656
```

### MultiQC
```
Ewels, P., Magnusson, M., Lundin, S., & Käller, M. (2016). MultiQC: summarize analysis 
results for multiple tools and samples in a single report.
Bioinformatics, 32(19), 3047-3048.
doi: 10.1093/bioinformatics/btw354
```

### R and R packages

**R:**
```
R Core Team (2022). R: A language and environment for statistical computing.
R Foundation for Statistical Computing, Vienna, Austria.
Available online at: https://www.R-project.org/
```

**ggplot2:**
```
Wickham, H. (2016). ggplot2: Elegant Graphics for Data Analysis.
Springer-Verlag New York.
ISBN: 978-3-319-24277-4
```

**dplyr:**
```
Wickham, H., François, R., Henry, L., & Müller, K. (2022). dplyr: A Grammar of Data Manipulation.
R package version 1.0.9.
Available online at: https://CRAN.R-project.org/package=dplyr
```

**tidyr:**
```
Wickham, H., & Henry, L. (2022). tidyr: Tidy Messy Data.
R package version 1.2.0.
Available online at: https://CRAN.R-project.org/package=tidyr
```

## Reference Genomes

### Human Genome (hg19/GRCh37)
```
Genome Reference Consortium (2009). Genome Reference Consortium Human Build 37 (GRCh37).
Available from: http://www.ncbi.nlm.nih.gov/projects/genome/assembly/grc/
```

### Human Genome (hg38/GRCh38)
```
Genome Reference Consortium (2013). Genome Reference Consortium Human Build 38 (GRCh38).
Available from: http://www.ncbi.nlm.nih.gov/projects/genome/assembly/grc/human/
```

### Mouse Genome (mm10/GRCm38)
```
Genome Reference Consortium (2011). Genome Reference Consortium Mouse Build 38 (GRCm38).
Available from: http://www.ncbi.nlm.nih.gov/projects/genome/assembly/grc/mouse/
```

## Blacklist Regions

```
Amemiya, H.M., Kundaje, A., & Boyle, A.P. (2019). The ENCODE Blacklist: Identification of 
Problematic Regions of the Genome.
Scientific Reports, 9(1), 9354.
doi: 10.1038/s41598-019-45839-z
```

## ATAC-seq Guidelines

**ENCODE ATAC-seq Guidelines:**
```
ENCODE Project Consortium (2020). ATAC-seq Data Standards and Processing Pipeline.
Available online at: https://www.encodeproject.org/atac-seq/
```

## Example BibTeX Entry

For LaTeX/BibTeX users, here's an example entry:

```bibtex
@article{buenrostro2013atac,
  title={Transposition of native chromatin for fast and sensitive epigenomic profiling of open chromatin, DNA-binding proteins and nucleosome position},
  author={Buenrostro, Jason D and Giresi, Paul G and Zaba, Lisa C and Chang, Howard Y and Greenleaf, William J},
  journal={Nature methods},
  volume={10},
  number={12},
  pages={1213--1218},
  year={2013},
  publisher={Nature Publishing Group},
  doi={10.1038/nmeth.2688}
}

@article{langmead2012bowtie2,
  title={Fast gapped-read alignment with Bowtie 2},
  author={Langmead, Ben and Salzberg, Steven L},
  journal={Nature methods},
  volume={9},
  number={4},
  pages={357--359},
  year={2012},
  publisher={Nature Publishing Group},
  doi={10.1038/nmeth.1923}
}

@article{ramirez2016deeptools,
  title={deepTools2: a next generation web server for deep-sequencing data analysis},
  author={Ram{\\'\\i}rez, Fidel and Ryan, Devon P and Gr{\\"u}ning, Bj{\\\"o}rn and Bhardwaj, Vivek and Kilpert, Fabian and Richter, Andreas S and Heyne, Steffen and D{\\\"u}ndar, Friederike and Manke, Thomas},
  journal={Nucleic acids research},
  volume={44},
  number={W1},
  pages={W160--W165},
  year={2016},
  publisher={Oxford University Press},
  doi={10.1093/nar/gkw257}
}
```

---

## How to Cite This Pipeline

If you use this pipeline in your research, please cite it as:

```
[Your Name] (2026). ATAC-seq Analysis Pipeline (Version 1.0.0) [Software].
Available from: https://github.com/yourusername/ATAC-seq-pipeline
```

**BibTeX:**
```bibtex
@software{atac_pipeline2026,
  author = {[Your Name]},
  title = {ATAC-seq Analysis Pipeline},
  year = {2026},
  version = {1.0.0},
  url = {https://github.com/yourusername/ATAC-seq-pipeline}
}
```

---

**Thank you for citing the tools and methods used in your research!**
