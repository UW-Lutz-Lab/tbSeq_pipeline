def SamtoolsMpileup(
    reference, reads, min_quality, output) {
    """
    $workflow.projectDir/pipeline_scripts/GeneratePileup.sh \
    --reference ${reference} \
    --reads ${reads} \
    --min_quality ${min_quality} \
    --max_depth 30000 \
    --output ${output}
    """
}

process GeneratePileup {

    input:
    path reads
    path read_index
    val read_alias
    val reference
    val min_quality

    output:
    path "*.pileup"
    val read_alias

    script:
        """
        ${SamtoolsMpileup(reference, reads, min_quality, read_alias)}    
        """
    // """
    // $workflow.projectDir/pipeline_scripts/GeneratePileup.sh \
    // --reference ${reference}
    // --reads ${reads}
    // --min_quality ${min_quality}
    // --output ${read_alias}
    // """

}