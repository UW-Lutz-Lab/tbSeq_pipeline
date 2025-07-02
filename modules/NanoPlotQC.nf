include { 
    MakeDirectory;
    SortBam;
    QCReads } from "./ShellCommands.nf"

// ======================
// NanoPlotQC_Unaligned
// ======================
/*
 * Runs QC analysis on unaligned sequencing reads:
 *   1. Creates a results directory for QC output.
 *   2. Sorts the input BAM file (for consistent downstream QC).
 *   3. Runs NanoPlot to generate summary QC metrics and visualizations.
 *
 * Inputs:
 *   reads (path):         Input BAM file (unaligned or unsorted).
 *   input_type (val):     NanoPlot input type (e.g., "bam").
 *   read_alias (val):     Prefix or alias for output files/directories.
 *
 * Output:
 *   ${read_alias}_unaligned_qc - Directory containing NanoPlot QC results.
 *
 * Assumptions:
 *   - Input BAM is valid and compatible with samtools and NanoPlot.
 *   - Required tools (samtools, NanoPlot) are available in the PATH.
 *   - Output directory is writeable.
 */
process NanoPlotQC_Unaligned {
    tag "QCing Unfiltered Reads: ${read_alias}"

    input:
        tuple(
            path(reads), 
            val(input_type), 
            val(read_alias)
        )

    output:
        path("${read_alias}_unaligned_qc")

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    set -x
    ${MakeDirectory("${read_alias}_unaligned_qc")}
    ${SortBam(reads, "${read_alias}_unaligned_sorted.bam")}
    ${QCReads("${read_alias}_unaligned_qc", input_type, "${read_alias}_unaligned_sorted.bam")}
    """
}

// ======================
// NanoPlotQC_Aligned
// ======================
/*
 * Runs QC analysis on aligned sequencing reads:
 *   1. Sorts the input BAM file (to ensure compatibility with QC tools).
 *   2. Runs NanoPlot to generate QC metrics and visualizations for the aligned reads.
 *
 * Inputs:
 *   reads (path):         Input BAM file (aligned).
 *   input_type (val):     NanoPlot input type (e.g., "bam").
 *   read_alias (val):     Prefix or alias for output files/directories.
 *
 * Output:
 *   ${read_alias}_aligned_qc - Directory containing NanoPlot QC results for aligned reads.
 *
 * Assumptions:
 *   - Input BAM is valid and aligned, and compatible with samtools and NanoPlot.
 *   - Required tools (samtools, NanoPlot) are available in the PATH.
 *   - Output directory is writeable.
 *   - Process uses 'errorStrategy ignore' to continue even if QC fails (optional).
 */
process NanoPlotQC_Aligned {
    errorStrategy 'ignore'
    tag "QCing Aligned Reads: ${read_alias}"

    input:
        tuple(
            path(reads), 
            val(input_type), 
            val(read_alias)
        )

    output:
        path("${read_alias}_aligned_qc")

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        """
        set -x
        ${SortBam("${reads}", "${read_alias}_aligned_sorted.bam")}
        ${QCReads("${read_alias}_aligned_qc", "${input_type}", "${read_alias}_aligned_sorted.bam")}
        """
}
