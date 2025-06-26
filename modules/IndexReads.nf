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

    def filename = reads.getName() 

    output:
    path "${filename}.bai"
    val read_alias

    script:
    """
    $workflow.projectDir/pipeline_scripts/IndexReads.sh \
    --reads ${reads}
    """

}