include { 
    SortBam;
    SamtoolsMpileup
    } from "./ShellCommands.nf"

// ======================
// GeneratePileup
// ======================
/*
 * Generates a pileup file from aligned sequencing reads for downstream variant calling.
 * First sorts the input BAM file, then runs samtools mpileup using the provided parameters.
 *
 * Inputs:
 *   reads (path):         Input BAM file (aligned reads).
 *   read_index (path):    BAM index file (not directly used here, but ensures BAM is indexed).
 *   read_alias (val):     Prefix or alias for output file naming.
 *   reference (val):      Reference FASTA file.
 *   min_quality (val):    Minimum base quality threshold for inclusion in the pileup.
 *
 * Output:
 *   tuple(
 *     *.pileup,       // Generated pileup file (named with read_alias)
 *     read_alias      // Alias for downstream tracking
 *   )
 *
 * Assumptions:
 *   - samtools is available in the PATH.
 *   - Input BAM is valid and sorted/indexed.
 *   - Output directory is writeable.
 */
process GeneratePileup {
    tag "Creating Mpileup: ${read_alias}"
    input:
        tuple(
            path(reads),
            path(read_index),
            val(read_alias),
            val(reference),
            val(min_quality)
        )

    output:
        tuple(
            path("*.pileup"),
            val(read_alias)
        )

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
        ${SortBam("${reads}", "${read_alias}_mp_aligned_sorted.bam")}
        ${SamtoolsMpileup("${reference}", "${read_alias}_mp_aligned_sorted.bam", "${min_quality}", 30000, "${read_alias}")}    
    """
}