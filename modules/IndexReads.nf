def IndexReads(reads, outfile_name) {
    """
    $workflow.projectDir/pipeline_scripts/SortBam.sh \
    --reads ${reads}
    """
}

process IndexReads {

    input:
    path reads
    val read_alias

    def filename = reads.getName() 

    output:
    path "${filename}.bai"

    script:
    IndexReads("${reads}")

}