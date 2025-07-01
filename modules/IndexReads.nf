// def RunIndexing(reads) {
//     """
//     $workflow.projectDir/pipeline_scripts/IndexReads.sh \
//     --reads ${reads}
//     """
// }

include { RunIndexing } from "./ShellCommands.nf"

process IndexReads {

    input:
        // val(reads)
        tuple(
            path(reads), 
            val(input_type), 
            val(read_alias)
        )

    output:
        tuple(
            path reads,
            path "*.bai",
            val read_alias,
            val reference
        )

    script:
    """
        ${RunIndexing(reads)}    
    """
    // """
    // $workflow.projectDir/pipeline_scripts/IndexReads.sh \
    // --reads ${reads}
    // """

}