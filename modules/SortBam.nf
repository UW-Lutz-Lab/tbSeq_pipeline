// def SortBam(reads, outfile_name) {
//     """
//     $workflow.projectDir/pipeline_scripts/SortBam.sh \
//     --reads ${reads} \
//     --outfile_name ${outfile_name}
//     """
// }

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

    // publishDir "${params.outdir}/${read.alias}", mode: 'copy'

    script:
        SortBam("${read.read_filepath}", "${read.alias}_unaligned_sorted.bam")

}

process SortBamAligned {
    input:
    path read
    val read_alias

    output:
    path "${read_alias}_sorted.bam"
    val read_alias

    // publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        SortBam("${read}", "${read_alias}_sorted.bam")
}
