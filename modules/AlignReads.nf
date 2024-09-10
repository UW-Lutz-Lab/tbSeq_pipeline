// process AlignReads {
//     tag "Aligning ${reads.baseName}"

//     input:
//     path reads
//     path ref

//     output:
//     path "${reads.baseName}_aligned.sam"

//     publishDir "${params.outdir}", mode: 'copy'

//     script:
//     """
//     $workflow.projectDir/pipeline_scripts/AlignReads.sh \
//     --reference ${ref} \
//     --reads ${reads} \
//     --output ${reads.baseName}_aligned.sam
//     """
// }

process AlignReads {
    tag "Aligning ${reads.baseName}"

    input:
    path reads
    path ref
    val read_alias

    output:
    path "${read_alias}_aligned.sam"
    val read_alias

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    $workflow.projectDir/pipeline_scripts/AlignReads.sh \
    --reference ${ref} \
    --reads ${reads} \
    --output ${read_alias}_aligned.sam 
    """
}
