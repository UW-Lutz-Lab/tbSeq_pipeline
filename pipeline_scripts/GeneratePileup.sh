#!/bin/bash
set -e

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --reference) reference="$2"; shift ;;
        --reads) reads="$2"; shift ;;
        --min_quality) min_quality="$2"; shift ;;
        --max_depth) max_depth="$2"; shift ;;
        --output) output="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

samtools mpileup -f ${reference} -B -Q ${min_quality} -d ${max_depth} ${reads} > ${output}_samtools.pileup