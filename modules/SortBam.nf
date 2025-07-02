include { SortBam } from "./ShellCommands.nf"

process SortBamUnaligned {

    input:
        val read

    output:
        tuple(
            path("${read.alias}_unaligned_sorted.bam"), 
            val(read.alias), 
            val("${read.ref_filepath}")
        )

    script:
        SortBam("${read.read_filepath}", "${read.alias}_unaligned_sorted.bam")

}

process SortBamAligned {
    input:
        tuple(
            path(reads),
            val(read_alias),
            val(reference)
        )

    output:
        tuple(
            path("${read_alias}_sorted.bam"),
            val(read_alias),
            val(reference)
        )
        
    script:
    """
        ${SortBam("${reads}", "${read_alias}_sorted.bam")}
    
    """
}
