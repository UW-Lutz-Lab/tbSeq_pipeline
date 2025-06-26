// def ReadIndexing(reads, outfile_name) {
//     """
//     $workflow.projectDir/pipeline_scripts/IndexReads.sh \
//     --reads ${reads}
//     """
// }

process IndexReads {

    input:
    path reads
    val read_alias

    output:
    path "*.bai"
    val read_alias

    script:
    """
    $workflow.projectDir/pipeline_scripts/IndexReads.sh \
    --reads ${reads}
    """

}