include { 
    VarscanMpileup2Indel;
    VarscanMpileup2Snp;
    TabixVCF;
    BcftoolsConcat;
    ConcatVCFs } from "./ShellCommands.nf"

// ======================
// gqToPval
// ======================
/*
 * Converts genotype quality (GQ) from params to a p-value for filtering.
 *
 * Args:
 *   gq (Int or Float): Genotype quality score.
 *
 * Returns:
 *   Float: Corresponding p-value (probability of error).
 *
 * Notes:
 *   - For GQ >= 255, returns 0.0 (effectively zero error probability).
 *   - p-value is calculated as 10^(-GQ/10).
 */
def gqToPval(gq) {
    // Convert GQ (int or float) back to probability (p-value)
    if (gq >= 255) {
        return 0.0  // Indicates extremely low p-value, practically zero.
    }
    def pval = Math.pow(10, -gq / 10.0)
    return pval
}

// ======================
// CallVariants
// ======================
/*
 * Calls SNP and INDEL variants from a pileup file using VarScan2,
 * compresses and indexes the VCF output, and concatenates SNP and INDEL
 * results into a single VCF for downstream analysis.
 *
 * Inputs:
 *   mpileup (Path): Input SAMtools pileup file for variant calling.
 *   read_alias (String): Sample identifier used for tagging output files.
 *
 * Outputs:
 *   *.vcf - Uncompressed VCF files containing SNP or INDEL variant calls.
 *   *.vcf.gz - Compressed VCF files for SNP and INDEL variants.
 *   *.vcf.gz - Concatenated VCF file containing all variant calls.
 *
 * Variant calling parameters:
 *   min_gq (Int): Minimum genotype quality threshold (converted to p-value).
 *   min_var_freq (Float): Minimum variant allele frequency required to call a variant.
 *   min_coverage (Int): Minimum read depth required to consider a position for calling.
 *
 * Steps:
 *   - Calls SNPs with Varscan2 using user-defined thresholds.
 *   - Compresses and indexes the SNP VCF.
 *   - Calls INDELs with Varscan2 using the same thresholds.
 *   - Compresses and indexes the INDEL VCF.
 *   - Concatenates SNP and INDEL VCFs into a single file for downstream use.
 *
 * Assumptions:
 *   - VarScan2, bgzip/tabix, and bcftools are available in the PATH.
 *   - The input pileup file is formatted for compatibility with VarScan2.
 *   - Output directory is specified by params.outdir.
 */

def min_pval = gqToPval(params.min_gq)
def min_var_freq = params.min_var_freq
def min_coverage = params.min_coverage

process CallVariants {
    tag "Calling Variants: ${read_alias}"
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
            "${read_alias}_varscan_final"
        )}    
    """
}