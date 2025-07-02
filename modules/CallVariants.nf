include { 
    VarscanMpileup2Indel;
    VarscanMpileup2Snp;
    TabixVCF;
    ConcatVCFs } from "./ShellCommands.nf"

def gqToPval(gq) {
    // Convert GQ (int or float) back to probability (p-value)
    if (gq >= 255) {
        return 0.0  // Indicates extremely low p-value, practically zero.
    }
    def pval = Math.pow(10, -gq / 10.0)
    return pval
}

def min_pval = gqToPval(params.min_gq)
def min_var_freq = params.min_var_freq
def min_coverage = params.min_coverage

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
        ${VarscanMpileup2Snp(
            "${mpileup}",
            "${min_var_freq}",
            "${min_coverage}",
            "${min_pval}",
            "${read_alias}_varscan_snps"
        )} && \
        ${TabixVCF("${read_alias}_varscan_snps.vcf.gz")} && \
        ${VarscanMpileup2Indel(
            "${mpileup}",
            "${min_var_freq}",
            "${min_coverage}",
            "${min_pval}",
            "${read_alias}_varscan_indels"
        )} && \
        ${TabixVCF("${read_alias}_varscan_indels.vcf.gz")}  && \
        ${ConcatVCFs(
            "${read_alias}_varscan_indels.vcf.gz",
            "${read_alias}_varscan_snps.vcf.gz",
            "${read_alias}_varscan_comb"
        )}    
    """
}