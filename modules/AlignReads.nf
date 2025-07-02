include { 
    AlignWithBowtie2;
    AlignWithMinimap2 
    } from "./ShellCommands.nf"

// ======================
// Bowtie2Alignment
// ======================
/*
 * Aligns sequencing reads to a reference genome using Bowtie2,
 * producing a SAM file of alignments.
 *
 * Inputs:
 *   reads (path):         Input reads file (FASTQ/FASTA) to align.
 *   read_alias (val):     Prefix or alias for output files.
 *   reference (val):      Path to the reference FASTA file.
 *
 * Output:
 *   tuple(
 *     ${read_alias}_bt2_aligned.sam,  // SAM file with alignments
 *     read_alias,                     // Alias for tracking
 *     reference                       // Reference file path
 *   )
 *
 * Assumptions:
 *   - Bowtie2 is available in the PATH.
 *   - Input reads and reference are valid and compatible.
 *   - Output directory is writeable.
 */
process Bowtie2Alignment {
    tag "Aligning w/ bowtie2 ${reads.baseName}"

    input:
        tuple(
            path(reads),
            val(read_alias),
            val(reference)
        )

    output:
        tuple(
            path("${read_alias}_bt2_aligned.sam"),
            val(read_alias),
            val(reference)
        )

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        """
        ${AlignWithBowtie2(reads, "${read_alias}_bt2_aligned.sam", reference)}
        """
}

// ======================
// Minimap2Alignment
// ======================
/*
 * Aligns sequencing reads to a reference sequence using minimap2
 * with user-specified k-mer size and minimizer window, producing
 * a SAM file of alignments.
 *
 * Inputs:
 *   reads (path):             Input reads file (FASTQ/FASTA, etc.).
 *   read_alias (val):         Prefix or alias for output files.
 *   reference (path):         Path to the reference FASTA file.
 *
 * Output:
 *   ${read_alias}_mm2_aligned.sam - SAM file containing minimap2 alignments.
 *   read_alias                   - Alias for downstream tracking.
 *   reference                    - Reference file path for downstream processes.
 *
 * Assumptions:
 *   - minimap2 is available in the PATH.
 *   - Input reads and reference files are valid and compatible.
 *   - Alignment parameters k and w are provided in params.alignment_settings.
 *   - Output directory is writeable.
 */
process Minimap2Alignment {
    tag "Aligning with minimap2 ${reads.baseName}"

    input:
    path reads
    val read_alias
    path reference

    output:
    path "${read_alias}_mm2_aligned.sam"
    val read_alias
    path reference

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        """
        ${AlignWithMinimap2(params.alignment_settings[params.alignment_type].k
        params.alignment_settings[params.alignment_type].w, 
        reads, 
        "${read_alias}_mm2_aligned.sam")}
        """

}
