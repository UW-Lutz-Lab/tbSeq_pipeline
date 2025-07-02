include { 
    VarscanMpileup2Indel;
    VarscanMpileup2Snp;
    TabixVCF;
    ConcatVCFs } from "./ShellCommands.nf"

process CallVariants {

    input:
        tuple(
            path(mpileup),
            val(read_alias)
        )

    output:
        tuple(
            path("*.vcf"),
            path("*.vcf.gz"),
            path("*.vcf.gz"),
        )
    
    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
        ${VarscanMpileup2Snp("${mpileup}", "${read_alias}_varscan_snps")} && \
        ${TabixVCF("${read_alias}_varscan_snps.vcf.gz")} && \
        ${VarscanMpileup2Indel("${mpileup}", "${read_alias}_varscan_indels")} && \
        ${TabixVCF("${read_alias}_varscan_indels.vcf.gz")}  && \
        ${ConcatVCFs("${read_alias}_varscan_indels.vcf.gz", "${read_alias}_varscan_snps.vcf.gz", "${read_alias}_varscan_comb")}    
    """
}