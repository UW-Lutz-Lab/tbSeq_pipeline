def CallVariants(
    mpileup, output) {
    """
    $workflow.projectDir/pipeline_scripts/CallVariants.sh \
    --mpileup ${mpileup}
    --output ${output}
    """
}

process CallVariants {

    input:
    path pileup
    val read_alias

    output:
    path "${read_alias}_varscan_combined.vcf"

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    CallVariants(mpileup, output)

}