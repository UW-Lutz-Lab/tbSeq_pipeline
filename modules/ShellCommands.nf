// def Bam2FqQualLenFilter(
//     reads,
//     output,
//     min_quality_filter,
//     max_quality_filter,
//     minlength,
//     maxlength) {
//     """
//     samtools bam2fq "${reads}" | chopper \
//     --quality "${min_quality_filter}" \
//     --maxqual "${max_quality_filter}" \
//     --minlength "${minlength}" \
//     --maxlength "${maxlength}" > "${output}"
//     """
// }

// def ConcatVCFs(
//     vcf1,
//     vcf2,
//     read_alias
// ) {
//     return """
//     bcftools concat -a ${vcf1} ${vcf2} -Oz -o ${read_alias}.vcf.gz
//     gunzip -c ${read_alias}.vcf.gz > ${read_alias}.vcf
//     """.stripIndent().trim()
// }

def BcftoolsConcat(vcfs, read_alias) {
    """
    bcftools concat -a ${vcfs.join(' ')} -Oz -o ${read_alias}.vcf.gz
    gunzip -c ${read_alias}.vcf.gz > ${read_alias}.vcf
    """.stripIndent().trim()
}

def TabixVCF(
    vcf
) {
    return "tabix -p vcf ${vcf}"
}

def VarscanMpileup2Indel(
    mpileup,
    read_alias
) {
    return """
    varscan mpileup2indel "${mpileup}" \
        --min-var-freq 0.001 \
        --min-reads2 2 \
        --min-coverage 10 \
        --p-value 0.01 \
        --output-vcf 1 | bgzip -c > "${read_alias}_varscan_indels.vcf.gz"
    """.stripIndent().trim()
}

def VarscanMpileup2Snp(
    mpileup,
    read_alias
) {
    return """
    varscan mpileup2snp "${mpileup}" \
        --min-var-freq 0.001 \
        --min-reads2 2 \
        --min-coverage 10 \
        --p-value 0.01 \
        --output-vcf 1 | bgzip -c > "${read_alias}_varscan_snps.vcf.gz"
    """.stripIndent().trim()
}


def SamtoolsMpileup(
    reference,
    reads,
    min_quality,
    max_depth=30000,
    read_alias
) {
    return """
    samtools mpileup -f "${reference}" \
        -B \
        -Q "${min_quality}" \
        -d "${max_depth}" \
        "${reads}" > "${read_alias}_samtools.pileup"
    """.stripIndent().trim()
}


def RunIndexing(reads){
    return "samtools index ${reads}"
}

// def DetermineCoverage(reads, read_alias){
//     return "samtools depth -a ${reads} | awk '{OFS=","; print \$1, \$2, \$3}' > ${read_alias}_coverage_report.csv"
// }

def DetermineCoverage(reads, read_alias) {
    return "samtools depth -a ${reads} | awk 'BEGIN{OFS=\",\"} {print \$1, \$2, \$3}' > ${read_alias}_coverage_report.csv"
}


def Bam2FqQualLenFilter(
    reads,
    output,
    min_quality_filter,
    max_quality_filter,
    minlength,
    maxlength
) {
    return """
    samtools bam2fq "${reads}" | chopper \
        --quality "${min_quality_filter}" \
        --maxqual "${max_quality_filter}" \
        --minlength "${minlength}" \
        --maxlength "${maxlength}" > "${output}"
    """.stripIndent().trim()
}



def MakeDirectory(outdir){
    return "mkdir -p ${outdir}"
}

// def QCReads(outdir, input_type, reads){
//     """
//     NanoPlot --only-report \
//     -o ${outdir} \
//     --${input_type} \
//     ${reads} 
//     """
// }

def QCReads(outdir, input_type, reads){
    return """
    NanoPlot --only-report \
        -o ${outdir} \
        --${input_type} \
        ${reads}
    """.stripIndent().trim()
}


def SortBam(reads, output) {
    return "samtools sort -o ${output} ${reads}"
}

// bowtie 2
// def BuildBowtieRefIndex(reference, ref_index="ref_index") {
//     return "bowtie2-build ${reference} ${ref_index}"
// }

// def AlignWithBowtie2(reads, output, reference) {
//     """
//     # Build bowtie2 index
//     bowtie2-build ${reference} "ref_index"
//     # Align reads
//     bowtie2 -x "ref_index" \
//     -U ${reads} \
//     -S ${output} \
//     --very-sensitive-local    
//     """
// }

// def AlignWithBowtie2(reads, output, reference, ref_index="ref_index") {
//     return """
//     # Derive index base name
//     index_base="ref_index"

//     # Build bowtie2 index
//     bowtie2-build "${reference}" "$index_base"

//     # Align reads
//     bowtie2 -x "$index_base" -U "${reads}" -S "${output}" --very-sensitive-local
//     """.stripIndent().trim()
// }

def AlignWithBowtie2(reads, output, reference, ref_index="ref_index") {
    return """
    set -e
    echo "reads: ${reads}"
    echo "reference: ${reference}"
    ls -lh "${reads}" "${reference}"

    # Build bowtie2 index
    bowtie2-build "${reference}" "${ref_index}"

    # Align reads
    bowtie2 -x "${ref_index}" -U "${reads}" -S "${output}" --very-sensitive-local
    """.stripIndent().trim()
}



// minimap2
def AlignWithMinimap2(k, w, reference, reads, output) {
    return """
    minimap2 -k ${k} -w ${w} -ax sr \
    ${reference} ${reads} > ${output}    
    """.stripIndent().trim()
}