include { 
    Bam2FqQualLenFilter;
    SortBam } from "./ShellCommands.nf"

// ======================
// BamConvertQualFilter
// ======================
/*
 * Converts a BAM file to a quality- and length-filtered FASTQ file.
 * First sorts the BAM file for compatibility, then uses samtools and chopper
 * to perform the conversion and filtering.
 *
 * Inputs:
 *   reads (path):               Input BAM file to convert and filter.
 *   read_alias (val):           Prefix or alias for output files.
 *   reference (path):           Reference file path (passed along for downstream use).
 *   min_quality_filter (val):   Minimum average base quality for reads to retain.
 *   max_quality_filter (val):   Maximum average base quality for reads to retain.
 *   minlength (val):            Minimum read length to retain.
 *   maxlength (val):            Maximum read length to retain.
 *
 * Output:
 *   tuple(
 *     ${read_alias}_f${min_quality_filter}.fastq,  // Filtered FASTQ file
 *     read_alias,                                  // Alias for downstream tracking
 *     reference                                    // Reference file path for downstream use
 *   )
 *
 * Assumptions:
 *   - samtools and chopper are available in the PATH.
 *   - Input BAM file is valid.
 *   - Output directory is writeable.
 */
process BamConvertQualFilter {
    tag "Converting ${read_alias} to Fastq"

    input:
        tuple(
            path(reads),
            val(read_alias),
            path(reference),
            val(min_quality_filter),
            val(max_quality_filter),
            val(minlength),
            val(maxlength)
        )

    output:
        tuple(
            path("${read_alias}_f${min_quality_filter}-${max_quality_filter}.fastq"),
            val(read_alias),
            path(reference)
        )
    
    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        """
        ${SortBam(reads, "${read_alias}_sorted")} &&\
        ${Bam2FqQualLenFilter(
            "${read_alias}_sorted",
            "${read_alias}_f${min_quality_filter}-${max_quality_filter}.fastq",
            min_quality_filter,
            max_quality_filter,
            minlength,
            maxlength
        )}
        """
}