// def SamtoolsMpileup(
//     reference, reads, min_quality, max_depth, output) {
//     """
//     $workflow.projectDir/pipeline_scripts/GeneratePileup.sh \
//     --reference ${reference}
//     --reads ${reads}
//     --min_quality ${min_quality}
//     --max_depth ${max_depth}
//     --output ${output}
//     """
// }

process GeneratePileup {

    input:
    path reads
    path read_index
    val read_alias
    path reference

    output:
    path "${read_alias}_samtools.pileup"

    script:
    """
    $workflow.projectDir/pipeline_scripts/GeneratePileup.sh \
    --reference ${reference}
    --reads ${reads}
    --min_quality ${min_quality}
    --max_depth ${max_depth}
    --output ${output}
    """

}