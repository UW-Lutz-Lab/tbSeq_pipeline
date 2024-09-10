#!/bin/bash
set -e
# Usage: ./SortBam.sh --reads <reads> --outfile_ext <output file name>

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --reads) reads="$2"; shift ;;
        --outfile_name) output="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

samtools sort -o ${output} ${reads}
