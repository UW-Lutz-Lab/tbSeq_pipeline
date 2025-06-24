process AlignReads {
    tag "Aligning w/ bowtie2 ${reads.baseName}"

    input:
    path reads
    val read_alias
    val read

    output:
    path "${read_alias}_aligned_bt2.sam"
    val read_alias

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    bash $workflow.projectDir/pipeline_scripts/AlignReads_bowtie2.sh \
        --reference ${read.ref_filepath} \
        --reads ${reads} \
        --output ${read_alias}_aligned_bt2.sam
    """
}
