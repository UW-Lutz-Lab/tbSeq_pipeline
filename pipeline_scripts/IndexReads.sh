#!/bin/bash
set -e
# Usage: ./IndexReads.sh --reads <reads>

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --reads) reads="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

samtools ${reads}