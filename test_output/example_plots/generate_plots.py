#!/usr/bin/env python3
"""
Generate Publication-Ready Example Plots for ATAC-seq Pipeline
These plots demonstrate the expected output quality from the pipeline.
"""

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.gridspec import GridSpec
import seaborn as sns

# Set publication-quality defaults
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.size'] = 10
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = ['Arial', 'DejaVu Sans']
sns.set_palette("Set2")

# ==============================================================================
# 1. Fragment Size Distribution
# ==============================================================================

def plot_fragment_size_distribution():
    """Generate fragment size distribution plot"""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    # Simulate realistic fragment size distribution for 3 samples
    fragment_sizes = np.arange(0, 1000, 1)
    
    for i, (sample, color) in enumerate([
        ('GM12878_Rep1', '#66C2A5'),
        ('GM12878_Rep2', '#FC8D62'),
        ('GM12878_Rep3', '#8DA0CB')
    ]):
        # NFR peak (~80bp)
        nfr = 0.4 * np.exp(-0.5 * ((fragment_sizes - 80) / 20)**2)
        # Mononucleosome (~200bp)
        mono = 0.25 * np.exp(-0.5 * ((fragment_sizes - 200) / 30)**2)
        # Dinucleosome (~400bp)
        di = 0.15 * np.exp(-0.5 * ((fragment_sizes - 400) / 40)**2)
        # Trinucleosome (~600bp)
        tri = 0.08 * np.exp(-0.5 * ((fragment_sizes - 600) / 50)**2)
        # Background
        background = 0.02 * np.exp(-fragment_sizes / 200)
        
        # Add noise
        density = nfr + mono + di + tri + background
        noise = np.random.normal(0, 0.01, len(density))
        density = density + noise
        density[density < 0] = 0
        
        ax.plot(fragment_sizes, density, label=sample, linewidth=2, color=color, alpha=0.8)
    
    ax.set_xlabel('Fragment Size (bp)', fontsize=12, fontweight='bold')
    ax.set_ylabel('Density', fontsize=12, fontweight='bold')
    ax.set_title('Fragment Size Distribution', fontsize=14, fontweight='bold', pad=15)
    ax.set_xlim(0, 800)
    ax.legend(loc='upper right', frameon=True, shadow=True)
    ax.grid(True, alpha=0.3, linestyle='--')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    
    # Add annotations
    ax.axvline(80, color='gray', linestyle='--', alpha=0.5, linewidth=1)
    ax.text(80, ax.get_ylim()[1]*0.95, 'NFR\n(~80bp)', ha='center', fontsize=9, 
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    ax.axvline(200, color='gray', linestyle='--', alpha=0.5, linewidth=1)
    ax.text(200, ax.get_ylim()[1]*0.95, 'Mono\n(~200bp)', ha='center', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('fragment_size_distribution.png', dpi=300, bbox_inches='tight')
    plt.savefig('fragment_size_distribution.pdf', bbox_inches='tight')
    print("✓ Created fragment_size_distribution.png/pdf")
    plt.close()

# ==============================================================================
# 2. TSS Enrichment Profile
# ==============================================================================

def plot_tss_enrichment():
    """Generate TSS enrichment profile"""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    positions = np.arange(-3000, 3001, 10)
    
    for sample, color in [
        ('GM12878_Rep1', '#66C2A5'),
        ('GM12878_Rep2', '#FC8D62'),
        ('GM12878_Rep3', '#8DA0CB')
    ]:
        # TSS enrichment profile
        enrichment = 8.5 * np.exp(-0.5 * (positions / 150)**2) + 1
        noise = np.random.normal(0, 0.2, len(enrichment))
        enrichment = enrichment + noise
        enrichment[enrichment < 0] = 0
        
        ax.plot(positions, enrichment, label=sample, linewidth=2, color=color, alpha=0.8)
    
    ax.axvline(0, color='red', linestyle='--', alpha=0.6, linewidth=1.5, label='TSS')
    ax.set_xlabel('Distance from TSS (bp)', fontsize=12, fontweight='bold')
    ax.set_ylabel('ATAC-seq Signal', fontsize=12, fontweight='bold')
    ax.set_title('TSS Enrichment Profile\nEnrichment Score: 8.5', 
                 fontsize=14, fontweight='bold', pad=15)
    ax.legend(loc='upper right', frameon=True, shadow=True)
    ax.grid(True, alpha=0.3, linestyle='--')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    
    plt.tight_layout()
    plt.savefig('TSS_enrichment_profile.png', dpi=300, bbox_inches='tight')
    plt.savefig('TSS_enrichment_profile.pdf', bbox_inches='tight')
    print("✓ Created TSS_enrichment_profile.png/pdf")
    plt.close()

# ==============================================================================
# 3. Sample Correlation Heatmap
# ==============================================================================

def plot_correlation_heatmap():
    """Generate sample correlation heatmap"""
    # Correlation matrix
    samples = ['Rep1', 'Rep2', 'Rep3']
    corr_matrix = np.array([
        [1.000, 0.954, 0.948],
        [0.954, 1.000, 0.962],
        [0.948, 0.962, 1.000]
    ])
    
    fig, ax = plt.subplots(figsize=(7, 6))
    
    # Create heatmap
    im = ax.imshow(corr_matrix, cmap='RdYlBu_r', aspect='auto', vmin=0.9, vmax=1.0)
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label('Pearson Correlation', rotation=270, labelpad=20, fontweight='bold')
    
    # Set ticks and labels
    ax.set_xticks(np.arange(len(samples)))
    ax.set_yticks(np.arange(len(samples)))
    ax.set_xticklabels(samples, fontsize=11)
    ax.set_yticklabels(samples, fontsize=11)
    
    # Add correlation values
    for i in range(len(samples)):
        for j in range(len(samples)):
            text = ax.text(j, i, f'{corr_matrix[i, j]:.3f}',
                          ha="center", va="center", color="black", fontsize=12, fontweight='bold')
    
    ax.set_title('Sample Correlation Heatmap\nPearson Correlation of Read Counts', 
                 fontsize=14, fontweight='bold', pad=15)
    
    plt.tight_layout()
    plt.savefig('correlation_heatmap.png', dpi=300, bbox_inches='tight')
    plt.savefig('correlation_heatmap.pdf', bbox_inches='tight')
    print("✓ Created correlation_heatmap.png/pdf")
    plt.close()

# ==============================================================================
# 4. Peak Distribution Bar Plot
# ==============================================================================

def plot_peak_distribution():
    """Generate peak genomic distribution plot"""
    features = ['Promoter\n(TSS)', 'Intron', 'Intergenic', 'Exon', 'TTS', "3' UTR", "5' UTR"]
    counts = [15234, 9823, 6745, 5234, 4892, 3456, 2439]
    percentages = [31.8, 20.5, 14.1, 10.9, 10.2, 7.2, 5.1]
    colors = plt.cm.Set3(np.linspace(0, 1, len(features)))
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Bar plot
    bars = ax1.barh(features, counts, color=colors, edgecolor='black', linewidth=1.5)
    ax1.set_xlabel('Number of Peaks', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Genomic Feature', fontsize=12, fontweight='bold')
    ax1.set_title('Peak Distribution Across Genomic Features', fontsize=14, fontweight='bold', pad=15)
    ax1.grid(axis='x', alpha=0.3, linestyle='--')
    
    # Add count labels
    for i, (bar, count) in enumerate(zip(bars, counts)):
        ax1.text(count + 300, i, f'{count:,}', va='center', fontsize=10, fontweight='bold')
    
    # Pie chart
    explode = [0.05 if p > 15 else 0 for p in percentages]
    wedges, texts, autotexts = ax2.pie(percentages, labels=features, autopct='%1.1f%%',
                                         colors=colors, explode=explode, shadow=True,
                                         startangle=90, textprops={'fontsize': 10, 'fontweight': 'bold'})
    ax2.set_title('Peak Distribution (%)', fontsize=14, fontweight='bold', pad=15)
    
    plt.tight_layout()
    plt.savefig('peak_distribution_barplot.png', dpi=300, bbox_inches='tight')
    plt.savefig('peak_distribution_barplot.pdf', bbox_inches='tight')
    print("✓ Created peak_distribution_barplot.png/pdf")
    plt.close()

# ==============================================================================
# 5. QC Metrics Summary
# ==============================================================================

def plot_qc_metrics():
    """Generate QC metrics plots"""
    samples = ['Rep1', 'Rep2', 'Rep3']
    mapping_rate = [95.5, 95.4, 95.4]
    duplication_rate = [26.7, 26.9, 26.6]
    frip_scores = [0.387, 0.402, 0.378]
    
    fig = plt.figure(figsize=(15, 5))
    gs = GridSpec(1, 3, figure=fig, hspace=0.3, wspace=0.3)
    
    colors = ['#66C2A5', '#FC8D62', '#8DA0CB']
    
    # Mapping Rate
    ax1 = fig.add_subplot(gs[0, 0])
    bars = ax1.bar(samples, mapping_rate, color=colors, edgecolor='black', linewidth=2)
    ax1.axhline(90, color='red', linestyle='--', linewidth=2, alpha=0.7, label='Minimum (90%)')
    ax1.set_ylabel('Mapping Rate (%)', fontsize=11, fontweight='bold')
    ax1.set_title('Mapping Rate by Sample', fontsize=13, fontweight='bold', pad=10)
    ax1.set_ylim(80, 100)
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)
    for bar, rate in zip(bars, mapping_rate):
        ax1.text(bar.get_x() + bar.get_width()/2, rate + 0.5, f'{rate}%', 
                ha='center', fontsize=10, fontweight='bold')
    
    # Duplication Rate
    ax2 = fig.add_subplot(gs[0, 1])
    bars = ax2.bar(samples, duplication_rate, color=colors, edgecolor='black', linewidth=2)
    ax2.axhline(40, color='orange', linestyle='--', linewidth=2, alpha=0.7, label='Threshold (40%)')
    ax2.set_ylabel('Duplication Rate (%)', fontsize=11, fontweight='bold')
    ax2.set_title('PCR Duplication Rate', fontsize=13, fontweight='bold', pad=10)
    ax2.set_ylim(0, 100)
    ax2.legend()
    ax2.grid(axis='y', alpha=0.3)
    for bar, rate in zip(bars, duplication_rate):
        ax2.text(bar.get_x() + bar.get_width()/2, rate + 1, f'{rate}%', 
                ha='center', fontsize=10, fontweight='bold')
    
    # FRiP Score
    ax3 = fig.add_subplot(gs[0, 2])
    bars = ax3.bar(samples, frip_scores, color=colors, edgecolor='black', linewidth=2)
    ax3.axhline(0.3, color='green', linestyle='--', linewidth=2, alpha=0.7, label='Good (>0.3)')
    ax3.set_ylabel('FRiP Score', fontsize=11, fontweight='bold')
    ax3.set_title('Fraction of Reads in Peaks', fontsize=13, fontweight='bold', pad=10)
    ax3.set_ylim(0, 0.5)
    ax3.legend()
    ax3.grid(axis='y', alpha=0.3)
    for bar, score in zip(bars, frip_scores):
        ax3.text(bar.get_x() + bar.get_width()/2, score + 0.01, f'{score:.3f}', 
                ha='center', fontsize=10, fontweight='bold')
    
    plt.suptitle('Quality Control Metrics Summary', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('qc_metrics_summary.png', dpi=300, bbox_inches='tight')
    plt.savefig('qc_metrics_summary.pdf', bbox_inches='tight')
    print("✓ Created qc_metrics_summary.png/pdf")
    plt.close()

# ==============================================================================
# 6. Read Counts Progression
# ==============================================================================

def plot_read_progression():
    """Generate read counts through pipeline"""
    samples = ['Rep1', 'Rep2', 'Rep3']
    raw_reads = [52.8, 48.9, 51.3]
    trimmed_reads = [51.2, 47.5, 49.8]
    mapped_reads = [48.9, 45.3, 47.5]
    final_reads = [35.8, 33.1, 34.9]
    
    x = np.arange(len(samples))
    width = 0.2
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    ax.bar(x - 1.5*width, raw_reads, width, label='Raw Reads', color='#E78AC3', edgecolor='black')
    ax.bar(x - 0.5*width, trimmed_reads, width, label='Trimmed', color='#A6D854', edgecolor='black')
    ax.bar(x + 0.5*width, mapped_reads, width, label='Mapped', color='#FFD92F', edgecolor='black')
    ax.bar(x + 1.5*width, final_reads, width, label='Final (Dedup)', color='#66C2A5', edgecolor='black')
    
    ax.set_ylabel('Reads (Millions)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Sample', fontsize=12, fontweight='bold')
    ax.set_title('Read Counts Through Pipeline', fontsize=14, fontweight='bold', pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels(samples)
    ax.legend(loc='upper right', frameon=True, shadow=True)
    ax.grid(axis='y', alpha=0.3, linestyle='--')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    
    plt.tight_layout()
    plt.savefig('read_counts_progression.png', dpi=300, bbox_inches='tight')
    plt.savefig('read_counts_progression.pdf', bbox_inches='tight')
    print("✓ Created read_counts_progression.png/pdf")
    plt.close()

# ==============================================================================
# Main
# ==============================================================================

if __name__ == '__main__':
    print("Generating publication-ready plots for ATAC-seq pipeline...")
    print("=" * 60)
    
    plot_fragment_size_distribution()
    plot_tss_enrichment()
    plot_correlation_heatmap()
    plot_peak_distribution()
    plot_qc_metrics()
    plot_read_progression()
    
    print("=" * 60)
    print("✓ All plots generated successfully!")
    print("\nGenerated files:")
    print("  - fragment_size_distribution.png/pdf")
    print("  - TSS_enrichment_profile.png/pdf")
    print("  - correlation_heatmap.png/pdf")
    print("  - peak_distribution_barplot.png/pdf")
    print("  - qc_metrics_summary.png/pdf")
    print("  - read_counts_progression.png/pdf")
    print("\nUse these plots in your README and documentation!")
