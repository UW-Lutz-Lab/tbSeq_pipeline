include { 
    DetermineCoverage;
    } from "./ShellCommands.nf"

// ======================
// CoverageDepth
// ======================
/*
 * Calculates per-base read depth from a BAM file using samtools depth,
 * and outputs the coverage as a CSV report for downstream analysis or visualization.
 *
 * Inputs:
 *   reads (path):       Input BAM file for which coverage will be computed.
 *   read_alias (val):   Prefix or alias for output file naming.
 *   reference (val):    Reference file path (passed along for downstream use).
 *
 * Output:
 *   ${read_alias}_coverage_report.csv - CSV file containing per-base coverage (columns: CHROM, POS, DEPTH).
 *
 * Assumptions:
 *   - samtools and awk are available in the PATH.
 *   - Input BAM file is valid, sorted, and indexed if required.
 *   - Output directory is writeable.
 */
process CoverageDepth {
    tag "Getting Read Depth ${reads}"

    input:
        tuple(
            path(reads), 
            val(read_alias),
            val(reference)
        )

    output:
        path("${read_alias}_coverage_report.csv")

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
        ${SortBam("${reads}", "${reads.baseName}_sorted.bam")}
        ${DetermineCoverage("${reads.baseName}_sorted.bam", "${read_alias}")}
    """
}
