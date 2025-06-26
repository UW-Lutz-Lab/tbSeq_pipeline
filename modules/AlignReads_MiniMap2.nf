process AlignReads {
    tag "Aligning with minimap2 ${reads.baseName}"

    input:
    path reads
    path ref
    val read_alias

    output:
    path "${read_alias}_aligned_mm2.sam"
    val read_alias
    path reference

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    $workflow.projectDir/pipeline_scripts/AlignReads.sh \
    --reference ${ref} \
    --reads ${reads} \
    --output ${read_alias}_aligned_mm2.sam 
    """
}
