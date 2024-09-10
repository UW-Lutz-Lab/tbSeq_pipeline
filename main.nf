#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { SortBamUnaligned; SortBamAligned } from "./modules/SortBam.nf"
include { NanoPlotQC_Unaligned; NanoPlotQC_Aligned } from "./modules/NanoPlotQC.nf"
include { BamConvertQualFilter } from "./modules/BamConvertQualFilter.nf"
include { AlignReads } from "./modules/AlignReads.nf"
include { CoverageDepth } from "./modules/CoverageDepth.nf"
include { PlotCoverage } from "./modules/PlotCoverage.nf" 


// Read and parse the CSV file
samples = file(params.samplesheet)

def sample_data = []
samples.withReader { reader ->
    reader.readLine() // Skip the header
    reader.eachLine { line ->
        def fields = line.split(',')
        def alias = fields[0]
        def filepath = "${params.base_dir}/${fields[1]}"
        sample_data << [ alias: alias, filepath: filepath, reference: params.reference ]
    }
}

process CreateOutdir {
    input:
    val read

    script:
    """
    mkdir -p \"/processed_results/${read.alias}\"
    """
}

workflow {

    // NUMBER OF CORES CHECK

    // Get the number of available processors
    def availableCpus = Runtime.runtime.availableProcessors()

    // Check if there are at least 4 available CPUs
    if (availableCpus < 4) {
        error "The pipeline requires at least 4 CPU cores to run. Available: ${availableCpus}."
    }

    Channel
        .from( sample_data )
        .set { bam_channel }

    ref_ch = Channel.fromPath(params.reference)


    CreateOutdir(bam_channel)

    unaligned_sorted_reads = SortBamUnaligned(bam_channel)

    NanoPlotQC_Unaligned(
        unaligned_sorted_reads[0], 
        "ubam", 
        unaligned_sorted_reads[1])
    
    filtered_fastq = BamConvertQualFilter(
        unaligned_sorted_reads[0],
        params.quality_filter,
        params.minlength,
        params.maxlength,
        unaligned_sorted_reads[1],
        unaligned_sorted_reads[2])

    aligned_reads = AlignReads(
        filtered_fastq[0], 
        filtered_fastq[2],
        filtered_fastq[1])
    // aligned_sorted_reads = SortBamAligned(aligned_reads)
    aligned_sorted_reads = SortBamAligned(aligned_reads[0], aligned_reads[1])
    NanoPlotQC_Aligned(aligned_sorted_reads[0], "bam", aligned_sorted_reads[1])
    read_depth = CoverageDepth(aligned_sorted_reads[0], aligned_sorted_reads[1])
    // PlotCoverage(read_depth, aligned_sorted_reads[1])

}

