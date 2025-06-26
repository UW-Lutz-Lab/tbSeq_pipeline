#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { SortBamUnaligned; SortBamAligned } from "./modules/SortBam.nf"
include { NanoPlotQC_Unaligned; NanoPlotQC_Aligned } from "./modules/NanoPlotQC.nf"
include { BamConvertQualFilter } from "./modules/BamConvertQualFilter.nf"
include { AlignReads } from "./modules/AlignReads_bowtie2.nf"
include { CoverageDepth } from "./modules/CoverageDepth.nf"
include { PlotCoverage } from "./modules/PlotCoverage.nf" 
// include { IndexReads } from "./modules/IndexReads.nf"
// include { GeneratePileup } from "./modules/GeneratePileup.nf"


// Read and parse the CSV file
samples = file(params.samplesheet)

def sample_data = []
samples.withReader { reader ->
    reader.readLine() // Skip the header
    reader.eachLine { line ->
        def fields = line.split(',')
        def alias = fields[0]
        def read_filepath = "${params.base_dir}/${fields[1]}"
        def ref_filepath = "${params.reference_base_dir}/${fields[2]}"
        sample_data << [ alias: alias, read_filepath: read_filepath, ref_filepath: ref_filepath ]
    }
}

def saveConfig() {
    def configText = params.toString()   // Only user params, much safer!
    def configFile = file("${params.outdir}/pipeline_run_config.txt")

    configFile.parent.mkdirs()
    configFile.text = configText
    log.info "Saved used Nextflow params to ${configFile}"
}


process CreateOutdir {
    input:
    val read

    script:
    """
    mkdir -p \"/${params.outdir}/${read.alias}\"
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

    // ref_ch = Channel.fromPath(params.reference)


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
        filtered_fastq[1],
        filtered_fastq[2])

    // aligned_sorted_reads = SortBamAligned(aligned_reads)
    aligned_sorted_reads = SortBamAligned(aligned_reads[0], aligned_reads[1])
    NanoPlotQC_Aligned(aligned_sorted_reads[0], "bam", aligned_sorted_reads[1])
    read_depth = CoverageDepth(aligned_sorted_reads[0], aligned_sorted_reads[1])
    // index_reads = IndexReads(aligned_sorted_reads[0], aligned_sorted_reads[1])
    // pileup = GeneratePileup(aligned_sorted_reads[0], index_reads[0], aligned_reads[1], aligned_reads[2])
    // PlotCoverage(read_depth, aligned_sorted_reads[1])
    saveConfig()
}

// workflow.onComplete {
//     try {
//         def outDir = params.outdir ?: "./processed_results"
//         saveConfig(outDir)
//     } catch (Exception e) {
//         log.warn "Failed to save config onComplete: ${e.message}"
//     }
// }
