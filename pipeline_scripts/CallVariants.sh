#!/bin/bash
set -e
# Usage: ./CallVariants.sh --quality_filter <quality_filter> --reads <reads> --output <output sam file>

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --mpileup) mpileup="$2"; shift ;;
        --output) output="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

varscan mpileup2snp "$mpileup" --min-var-freq 0.001 --min-reads2 2 --min-coverage 10 --p-value 1 --output-vcf 1 > ${output}_varscan_snps.vcf 

varscan mpileup2indel "$mpileup" --min-var-freq 0.001 --min-reads2 2 --min-coverage 10 --p-value 1 --output-vcf 1 > ${output}_varscan_indels.vcf

