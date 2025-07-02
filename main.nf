#!/usr/bin/env nextflow

// ===========================
//       PIPELINE SETUP
// ===========================

// Use Nextflow DSL2 syntax (modern, modular, recommended)
nextflow.enable.dsl=2

// ----
// Import processes from module scripts
// ----
include { SortBamUnaligned; SortBamAligned } from "./modules/SortBam.nf"
include { NanoPlotQC_Unaligned; NanoPlotQC_Aligned } from "./modules/NanoPlotQC.nf"
include { BamConvertQualFilter } from "./modules/BamConvertQualFilter.nf"
include { Bowtie2Alignment; Minimap2Alignment } from "./modules/AlignReads.nf"
include { CoverageDepth } from "./modules/CoverageDepth.nf"
include { IndexReads } from "./modules/IndexReads.nf"
include { GeneratePileup } from "./modules/GeneratePileup.nf"
include { CallVariants } from "./modules/CallVariants.nf"

// Read and parse the CSV file
samples = file(params.samplesheet)

// ----
// Parse samplesheet and build sample data list
// 'sample_data' will store a list of maps, one for each sample
// ----
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

// ----
// Utility: Save used parameters to file for reproducibility
// ----
// This saves the parameters used in this pipeline run to a text file in the output directory.
def saveConfig() {
    def configText = params.toString()   // Only user params, much safer!
    def configFile = file("${params.outdir}/pipeline_run_config.txt")

    configFile.parent.mkdirs()
    configFile.text = configText
    log.info "Saved used Nextflow params to ${configFile}"
}

// ----
// Check and fetch alignment settings based on user input
// ----
def align_settings = params.alignment_type

// Check if the alignment type exists
// Ensure the user has selected a valid alignment type
if (!align_settings) {
    error "Alignment type '${params.alignment_type}' is not defined in the configuration. Available types: ${params.alignment_settings.keySet().join(', ')}"
}

// ----
// Utility process to create per-sample output directories
// ----
// Each sample's output goes into its own directory for organization
process CreateOutdir {
    input:
    val read_alias

    script:
    """
    mkdir -p \"/${params.outdir}/${read_alias}\"
    """
}

workflow {
    // =========================================
    //     SYSTEM CHECKS AND SAFETY GUARDS
    // =========================================

    // NUMBER OF CORES CHECK
    // Get the number of available processors
    def availableCpus = Runtime.runtime.availableProcessors()

    // Check if there are at least 4 available CPUs
    if (availableCpus < 4) {
        error "The pipeline requires at least 4 CPU cores to run. Available: ${availableCpus}."
    }

    // =========================================
    //     INPUT CHANNEL SETUP
    // =========================================

    // Create a channel from the sample_data 
    // list, each element is a sample Map

    Channel
        .from( sample_data )
        .set { bam_channel }

    // Create a channel of sample aliases (for directory creation)
    bam_channel.map { it.alias }
        .set { outdir_channel }

    // Create output directories for each sample
    CreateOutdir(outdir_channel)

    // Prepare input for initial QC process: 
    // (reads path, input type, alias)
    bam_channel.map { sample -> tuple(
        file(sample.read_filepath), 
        "ubam", 
        sample.alias ) 
        } .set { unaligned_qc_input_channel }

    // Run QC on raw/unfiltered reads
    NanoPlotQC_Unaligned(unaligned_qc_input_channel)

    // Prepare input for BAM -> FASTQ filtering process
    bam_channel.map { sample -> tuple(
        file(sample.read_filepath), 
        sample.alias, 
        file(sample.ref_filepath), 
        params.min_quality_filter,
        params.max_quality_filter,
        params.minlength,
        params.maxlength) 
        } .set { bam_filter_input_channel }

    // Run BAM-to-FASTQ conversion with quality and length filters applied    
    filtered_fastq_channel = BamConvertQualFilter(bam_filter_input_channel)

    // =========================================
    //           SEQUENCE ALIGNMENT
    // =========================================

    // Based on user parameter, select alignment tool
    if (params.alignment_type == 'minimap2') {
        // Run minimap2 with these specific params
        aligned_reads_channel = Minimap2Alignment(filtered_fastq_channel)
    }
    else if (params.alignment_type == 'bowtie2') {
        // Run bowtie2 with different params
        aligned_reads_channel = Bowtie2Alignment(filtered_fastq_channel)
    }

    // =========================================
    //     QC & COVERAGE OF ALIGNED READS
    // =========================================

    // Prepare input for QC on aligned reads
    aligned_qc_input_channel = aligned_reads_channel.map { 
        reads, read_alias, reference -> tuple(reads, "bam", read_alias) 
        }
    
    // Run QC on aligned BAMs
    NanoPlotQC_Aligned(aligned_qc_input_channel)

    // Compute coverage depth per sample
    read_depth = CoverageDepth(aligned_reads_channel)

    // Index aligned BAMs for downstream processes
    index_reads_channel = IndexReads(aligned_reads_channel)

    // =========================================
    //     VARIANT CALLING
    // =========================================

    // Prepare input for pileup generation (includes index and QC params)
    pileup_input_channel = index_reads_channel.map { 
        reads, reads_index, read_alias, reference -> tuple(
            reads, reads_index, read_alias, reference, params.min_quality_filter) 
        }

    // Generate pileup files for each sample
    pileups = GeneratePileup(pileup_input_channel)

    // Call variants from pileups (VCF output)
    CallVariants(pileups)

    // plot coverage;
    // PlotCoverage(read_depth, aligned_sorted_reads[1])

    // Save the configuration parameters
    saveConfig()
}