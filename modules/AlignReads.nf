
include { 
    BuildBowtieRefIndex;
    AlignWithBowtie2;
    AlignWithMinimap2 
    } from "./ShellCommands.nf"


// process Bowtie2Alignment {
//     tag "Aligning w/ bowtie2 ${reads.baseName}"

//     input:
//         tuple(
//             path(reads),
//             val(read_alias),
//             path(reference)
//         )
//     // path reads
//     // val read_alias
//     // path reference

//     output:
//         tuple(
//             path("${read_alias}_bt2_aligned.sam"),
//             val(read_alias),
//             path(reference)
//         )
//     // path "${read_alias}_bt2_aligned.sam"
//     // val read_alias
//     // path reference

//     publishDir "${params.outdir}/${read_alias}", mode: 'copy'

//     script:
//         BuildBowtieRefIndex(reference)
//         AlignReadsBowtie2(reads, "${read_alias}_bt2_aligned.sam")
//         // """
//         // bash $workflow.projectDir/pipeline_scripts/AlignReads_bowtie2.sh \
//         //     --reference ${reference} \
//         //     --reads ${reads} \
//         //     --output ${read_alias}_aligned_bt2.sam
//         // """
// }

process Bowtie2Alignment {
    tag "Aligning w/ bowtie2 ${reads.baseName}"

    input:
        tuple(
            path(reads),
            val(read_alias),
            path(reference)
        )

    output:
        tuple(
            path("${read_alias}_bt2_aligned.sam"),
            val(read_alias),
            path(reference)
        )

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        BuildBowtieRefIndex(reference)
        AlignWithBowtie2(reads, "${read_alias}_bt2_aligned.sam")
}

process Minimap2Alignment {
    tag "Aligning with minimap2 ${reads.baseName}"

    input:
    path reads
    val read_alias
    path reference

    output:
    path "${read_alias}_mm2_aligned.sam"
    val read_alias
    path reference

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
        AlignWithMinimap2(params.alignment_settings[params.alignment_type].k
        params.alignment_settings[params.alignment_type].w, 
        reads, 
        "${read_alias}_mm2_aligned.sam")

}
