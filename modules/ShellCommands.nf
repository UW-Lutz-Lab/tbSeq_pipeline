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