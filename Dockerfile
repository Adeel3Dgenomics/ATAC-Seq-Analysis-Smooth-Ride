FROM ubuntu:20.04

# Metadata
LABEL maintainer="your.email@institution.edu"
LABEL description="Docker container for ATAC-seq analysis pipeline"
LABEL version="1.0.0"

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /opt/atac-seq-pipeline

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    unzip \
    default-jdk \
    python3 \
    python3-pip \
    r-base \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libxt-dev \
    bc \
    && rm -rf /var/lib/apt/lists/*

# Install conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm /tmp/miniconda.sh

# Add conda to PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Copy environment file
COPY environment.yml /opt/atac-seq-pipeline/

# Create conda environment
RUN conda env create -f environment.yml \
    && conda clean -afy

# Activate environment in bash
RUN echo "source activate atac-seq" > ~/.bashrc
ENV PATH="/opt/conda/envs/atac-seq/bin:${PATH}"

# Install Genrich (not in conda)
RUN cd /opt && \
    git clone https://github.com/jsh58/Genrich.git && \
    cd Genrich && \
    make && \
    cp Genrich /usr/local/bin/ && \
    chmod +x /usr/local/bin/Genrich

# Copy pipeline scripts
COPY ATAC_main.sh /opt/atac-seq-pipeline/
COPY submit_ATAC.sh /opt/atac-seq-pipeline/
COPY config.example.sh /opt/atac-seq-pipeline/
COPY scripts/ /opt/atac-seq-pipeline/scripts/

# Make scripts executable
RUN chmod +x /opt/atac-seq-pipeline/*.sh && \
    chmod +x /opt/atac-seq-pipeline/scripts/*.sh

# Create mount points for data
RUN mkdir -p /data /refs

# Set environment variables
ENV BASE_DIR=/data/analysis
ENV RAW_DIR=/data/raw

# Default command
CMD ["/bin/bash"]

# Usage:
# docker build -t atac-seq:latest .
# docker run -v /path/to/data:/data -v /path/to/refs:/refs -it atac-seq:latest bash
