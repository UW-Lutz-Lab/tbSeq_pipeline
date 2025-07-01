// def RunIndexing(reads) {
//     """
//     $workflow.projectDir/pipeline_scripts/IndexReads.sh \
//     --reads ${reads}
//     """
// }

include { RunIndexing } from "./ShellCommands.nf"

process IndexReads {

    input:
    path reads
    val read_alias
    val reference

    output:
    path reads
    path "*.bai"
    val read_alias
    val reference

    script:
        """
        ${RunIndexing(reads)}
    
        """
    // """
    // $workflow.projectDir/pipeline_scripts/IndexReads.sh \
    // --reads ${reads}
    // """

}