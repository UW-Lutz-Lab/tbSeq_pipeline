def VarScan2(
    mpileup, output) {
    """
    $workflow.projectDir/pipeline_scripts/CallVariants.sh \
    --mpileup ${mpileup} \
    --output ${output}
    """
}

process CallVariants {

    input:
    path pileup
    val read_alias

    output:
    path "*.vcf"

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    $workflow.projectDir/pipeline_scripts/CallVariants.sh \
    --mpileup ${pileup}
    --output ${output}
    """

}