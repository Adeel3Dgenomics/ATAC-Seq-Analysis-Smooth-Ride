#!/bin/bash

# Script to generate example publication-ready plots
# Usage: bash generate_all_plots.sh

echo "=========================================="
echo "ATAC-seq Pipeline - Plot Generator"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "generate_plots.py" ]; then
    echo "Error: generate_plots.py not found!"
    echo "Please run this script from test_output/example_plots/ directory"
    exit 1
fi

# Check Python dependencies
echo "Checking dependencies..."
python3 -c "import matplotlib, numpy, pandas, seaborn" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "⚠ Missing dependencies. Installing..."
    pip install matplotlib numpy pandas seaborn
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install dependencies"
        echo "Try: pip install --user matplotlib numpy pandas seaborn"
        exit 1
    fi
fi

echo "✓ All dependencies satisfied"
echo ""

# Generate plots
echo "Generating publication-ready plots..."
echo "This will take 10-20 seconds..."
echo ""

python3 generate_plots.py

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✓ SUCCESS!"
    echo "=========================================="
    echo ""
    echo "Generated plots:"
    ls -lh *.png 2>/dev/null | awk '{print "  📊", $9, "("$5")"}'
    echo ""
    ls -lh *.pdf 2>/dev/null | awk '{print "  📄", $9, "("$5")"}'
    echo ""
    echo "View plots:"
    echo "  - On macOS: open *.png"
    echo "  - On Linux: eog *.png  or  feh *.png"
    echo "  - On Windows: explorer ."
    echo ""
    echo "Use these plots in your README and documentation!"
    echo "See VISUAL_GALLERY.md for usage examples."
else
    echo "Error: Plot generation failed"
    exit 1
fi
