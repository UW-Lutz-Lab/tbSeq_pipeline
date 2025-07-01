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
        tuple(
            path(reads),
            path(read_index),
            val(read_alias),
            val(reference),
            val(min_quality)
        )

    output:
        tuple(
            path("*.pileup"),
            val(read_alias),
            val(reference),
        )

    script:
        """
        ${SamtoolsMpileup(reference, reads, min_quality, read_alias)}    
        """
}