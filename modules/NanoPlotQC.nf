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
    QCReads } from "./ShellCommands.nf"

process NanoPlotQC_Unaligned {
    tag "NanoStats QC ${reads.baseName}"

    input:
        tuple(
            path(reads), 
            val(input_type), 
            val(read_alias)
        )
    // path reads
    // val input_type // --ubam
    // val read_alias

    output:
        path "${read_alias}_unaligned_qc"

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        MakeDirectory("${read_alias}_unaligned_qc")
        QCReads("${read_alias}_unaligned_qc", input_type, reads)
        // runNanoPlotQC(reads, "${reads.baseName}", input_type)
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
        QCReads("${read_alias}_aligned_qc", input_type, reads)
        // runNanoPlotQC(reads, "${reads.baseName}", input_type)
    // """
    // $workflow.projectDir/pipeline_scripts/NanoPlotQC.sh \
    // --reads ${reads} \
    // --input_type ${input_type} \
    // --out_dir ${reads.baseName}_qc
    // """
}
