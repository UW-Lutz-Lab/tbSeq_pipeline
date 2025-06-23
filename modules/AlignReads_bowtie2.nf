process AlignReads {
    tag "Aligning w/ bowtie2 ${reads.baseName}"

    input:
    path reads
    path ref
    val read_alias

    output:
    path "${read_alias}_aligned_bt2.sam"
    val read_alias

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    bash $workflow.projectDir/pipeline_scripts/AlignReads_bowtie2.sh \
        --reference ${ref} \
        --reads ${reads} \
        --output ${read_alias}_aligned_bt2.sam
    """
}
