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
    path mpileup
    val read_alias

    output:
    path "*.vcf"

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    VarScan2(mpileup, read_alias)
    // """
    // $workflow.projectDir/pipeline_scripts/CallVariants.sh \
    // --mpileup ${mpileup}
    // --output ${read_alias}
    // """
}