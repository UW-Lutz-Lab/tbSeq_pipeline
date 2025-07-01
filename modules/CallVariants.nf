include { 
    VarscanMpileup2Indel;
    VarscanMpileup2Snp;
    TabixVCF;
    ConcatVCFs } from "./ShellCommands.nf"

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
        tuple(
            path(mpileup),
            val(read_alias)
        )

    output:
        // path("*_snps.vcf")
        // path("*_indels.vcf")
        path("*.vcf")

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
        ${VarscanMpileup2Snp("${mpileup}", "${read_alias}")}
        ${TabixVCF("${read_alias}_varscan_snps.vcf.gz")}
        ${VarscanMpileup2Indel("${mpileup}", "${read_alias}")}
        ${TabixVCF("${read_alias}_varscan_indels.vcf.gz")} 
        ${ConcatVCFs(""${read_alias}_varscan_indels.vcf.gz", "${read_alias}_varscan_indels.vcf.gz", "${read_alias}")}    
    """
}