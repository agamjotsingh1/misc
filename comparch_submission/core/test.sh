#!/bin/bash

# Usage: ./run.sh <module> [submodule]

mod="$1"
submod="${2:-}"  # Optional second argument

# Validate mandatory module argument
if [ -z "$mod" ]; then
    echo "Error: Module name not provided!"
    echo "Usage: $0 <module> [submodule]"
    exit 1
fi

# Setup directories
build_dir="./build/${mod}"
mkdir -p "$build_dir"

# Check behavior based on arguments
if [ -n "$submod" ]; then
    # ------------------------------
    # Case 1: Submodule explicitly given
    # ------------------------------
    design="./${mod}/${submod}.v"
    tb="./tb/${mod}/${submod}_tb.v"

    if [ ! -f "$design" ]; then
        echo "Error: Design file not found -> $design"
        exit 1
    fi

    if [ ! -f "$tb" ]; then
        echo "Error: Testbench file not found -> $tb"
        exit 1
    fi

    echo "Compiling specific submodule: ${mod}/${submod}"
    iverilog -g2005-sv -o "${build_dir}/${submod}.vvp" "$tb" "$design"

    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed for ${mod}/${submod}"
        exit 1
    fi

    echo "✅ Compiled -> ${build_dir}/${submod}.vvp"
    vvp "${build_dir}/${submod}.vvp"

else
    # ------------------------------
    # Case 2: No submodule provided → build the whole module directory
    # ------------------------------
    design_dir="./${mod}"

    if [ ! -d "$design_dir" ]; then
        echo "Error: Module folder not found -> $design_dir"
        exit 1
    fi

    dep_files=$(find "$design_dir" -maxdepth 1 -type f -name "*.v" | sort)
    tb="./tb/${mod}/${mod}_tb.v"

    if [ ! -f "$tb" ]; then
        echo "Error: Expected top-level testbench not found -> $tb"
        exit 1
    fi

    echo "Detected top module: ${mod}"
    echo "Resolved dependencies:"
    echo "$dep_files"
    
    iverilog -g2005-sv -o "${build_dir}/${mod}.vvp" $tb $dep_files

    if [ $? -ne 0 ]; then
        echo "❌ Compilation failed for ${mod}"
        exit 1
    fi

    echo "✅ Compiled with dependencies -> ${build_dir}/${mod}.vvp"
    vvp "${build_dir}/${mod}.vvp"
fi
