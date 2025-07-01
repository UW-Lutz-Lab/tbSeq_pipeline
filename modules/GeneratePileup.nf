include { 
    SortBam;
    SamtoolsMpileup
    } from "./ShellCommands.nf"

// def SamtoolsMpileup(
//     reference, reads, min_quality, output) {
//     """
//     $workflow.projectDir/pipeline_scripts/GeneratePileup.sh \
//     --reference ${reference} \
//     --reads ${reads} \
//     --min_quality ${min_quality} \
//     --max_depth 30000 \
//     --output ${output}
//     """
// }

process GeneratePileup {

    input:
        tuple(
            path(reads),
            path(read_index),
            val(read_alias),
            val(reference),
            val(min_quality)
        )

    output:
        tuple(
            path("*.pileup"),
            val(read_alias)
        )

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
        ${SortBam("${reads}", "${read_alias}_mp_aligned_sorted.bam")}
        ${SamtoolsMpileup("${reference}", "${read_alias}_mp_aligned_sorted.bam", "${min_quality}", 30000, "${read_alias}")}    
    """
}