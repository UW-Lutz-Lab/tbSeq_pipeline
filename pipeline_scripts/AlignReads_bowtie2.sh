#!/bin/bash
set -e
# Usage: ./AlignReads_bowtie2.sh --reference <reference.fa> --reads <reads.fq> --output <output.sam>

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --reference) reference="$2"; shift ;;
        --reads) reads="$2"; shift ;;
        --output) output="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Derive index base name
index_base="ref_index"

# Build bowtie2 index
bowtie2-build "$reference" "$index_base"

# Align reads
bowtie2 -x "$index_base" -U "$reads" -S "$output" --very-sensitive-local
