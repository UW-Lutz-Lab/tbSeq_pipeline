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
        tuple path(reads), val(input_type), val(read_alias)
    // path reads
    // val input_type // --ubam
    // val read_alias

    output:
        path "${reads.baseName}_qc"

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        MakeDirectory("${reads.baseName}_qc")
        QCReads("${reads.baseName}_qc", input_type, reads)
        // runNanoPlotQC(reads, "${reads.baseName}", input_type)
}

process NanoPlotQC_Aligned {
    errorStrategy 'ignore'
    tag "NanoStats QC ${reads.baseName}"

    input:
    path reads
    val input_type // --bam
    val read_alias

    output:
    path "${reads.baseName}_qc"

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        runNanoPlotQC(reads, "${reads.baseName}", input_type)
    // """
    // $workflow.projectDir/pipeline_scripts/NanoPlotQC.sh \
    // --reads ${reads} \
    // --input_type ${input_type} \
    // --out_dir ${reads.baseName}_qc
    // """
}
