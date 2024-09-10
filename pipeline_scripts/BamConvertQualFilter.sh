#!/bin/bash
set -e
# Usage: ./BamConvertQualFilter.sh --quality_filter <quality_filter> --reads <reads> --output <output sam file>

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --reads) reads="$2"; shift ;;
        --output) output="$2"; shift ;;
        --quality_filter) quality_filter="$2"; shift;;
        --minlength) minlength="$2"; shift;;
        --maxlength) maxlength="$2"; shift;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

samtools bam2fq "$reads" | chopper --quality "$quality_filter" --minlength "$minlength"  --maxlength "$maxlength" > "$output"


