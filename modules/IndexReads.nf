include { 
    SortBam;
    RunIndexing 
    } from "./ShellCommands.nf"

// ======================
// IndexReads
// ======================
/*
 * Sorts a BAM file and generates a BAM index (.bai) for rapid random access by downstream tools.
 *
 * Inputs:
 *   reads (path):       Input BAM file to be sorted and indexed.
 *   read_alias (val):   Prefix or alias for output file naming and tracking.
 *   reference (val):    Reference file path (passed along for downstream use).
 *
 * Output:
 *   tuple(
 *     reads,                        // (Possibly unsorted) input BAM file
 *     *.bai,                        // BAM index file for the sorted BAM
 *     read_alias,                   // Alias for downstream tracking
 *     reference                     // Reference file path
 *   )
 *
 * Assumptions:
 *   - samtools is available in the PATH.
 *   - Input BAM file is valid.
 *   - Output directory is writeable.
 *   - Sorting step produces "${read_alias}_aligned_sorted.bam", and indexing is performed on this file.
 */
process IndexReads {

    input:
        // val(reads)
        tuple(
            path(reads), 
            val(read_alias),
            val(reference)
        )

    output:
        tuple(
            path(reads),
            path("*.bai"),
            val(read_alias),
            val(reference)
        )

    script:
    """
        ${SortBam("${reads}", "${read_alias}_aligned_sorted.bam")}
        ${RunIndexing("${read_alias}_aligned_sorted.bam")}    
    """
}