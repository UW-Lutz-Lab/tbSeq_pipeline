// def runNanoPlotQC(reads, out_dir, input_type) {
//     """
//     $workflow.projectDir/pipeline_scripts/NanoPlotQC.sh \
//     --reads ${reads} \
//     --input_type ${input_type} \
//     --out_dir ${out_dir}_qc
//     """
// }

include { 
    MakeDirectory;
    SortBam;
    QCReads } from "./ShellCommands.nf"

// process NanoPlotQC_Unaligned {
//     tag "NanoStats QC ${reads}"

//     input:
//         // val(reads)
//         tuple(
//             path(reads), 
//             val(input_type), 
//             val(read_alias)
//         )
//     // path reads
//     // val input_type // --ubam
//     // val read_alias

//     output:
//         path "${read_alias}_unaligned_qc"

//     publishDir "${params.outdir}/${read_alias}", mode: 'copy'

//     script:
//     """
//         set -x
//         ${MakeDirectory("${read_alias}_unaligned_qc")}
//         ${SortBam(reads, "${read_alias}_unaligned_sorted.bam")}
//         ${QCReads("${read_alias}_unaligned_qc", ${input_type}, "${read_alias}_unaligned_sorted.bam")}
//     """
//         // MakeDirectory("${read_alias}_unaligned_qc")
//         // SortBam("${reads}", "${read_alias}_unaligned_sorted.bam")
//         // QCReads("${read_alias}_unaligned_qc", "ubam", sorted_bam)
//         // runNanoPlotQC(reads, "${reads.baseName}", input_type)
// }

process NanoPlotQC_Unaligned {
    tag "NanoStats QC ${reads}"

    input:
        tuple(
            path(reads), 
            val(input_type), 
            val(read_alias)
        )

    output:
        path("${read_alias}_unaligned_qc")

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    set -x
    ${MakeDirectory("${read_alias}_unaligned_qc")}
    ${SortBam(reads, "${read_alias}_unaligned_sorted.bam")}
    ${QCReads("${read_alias}_unaligned_qc", input_type, "${read_alias}_unaligned_sorted.bam")}
    """
}

process NanoPlotQC_Aligned {
    errorStrategy 'ignore'
    tag "NanoStats QC ${reads.baseName}"

    input:
        tuple(
            path(reads), 
            val(input_type), 
            val(read_alias)
        )

    output:
        path("${read_alias}_aligned_qc")

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        """
        set -x
        ${SortBam(reads, "${read_alias}_aligned_sorted.bam")}
        ${QCReads("${read_alias}_unaligned_qc", "${input_type}", "${read_alias}_aligned_sorted.bam")}
        """

    // script:
    //     QCReads("${read_alias}_aligned_qc", input_type, reads)
        // runNanoPlotQC(reads, "${reads.baseName}", input_type)
    // """
    // $workflow.projectDir/pipeline_scripts/NanoPlotQC.sh \
    // --reads ${reads} \
    // --input_type ${input_type} \
    // --out_dir ${reads.baseName}_qc
    // """
}
