include { RunIndexing } from "./ShellCommands.nf"

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