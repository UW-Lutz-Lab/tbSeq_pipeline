process BamConvertQualFilter {
    tag "Converting ${reads.baseName} to Fastq"

    input:
    path reads
    // val reads
    val quality_level
    val minlength
    val maxlength
    val read_alias
    val reference

    output:
    path "${read_alias}_f${quality_level}.fastq"
    val read_alias 
    val reference
    // file "${reads.baseName}_aligned.sam"

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    $workflow.projectDir/pipeline_scripts/BamConvertQualFilter.sh \
    --quality_filter ${quality_level} \
    --reads ${reads} \
    --minlength ${minlength} \
    --maxlength ${maxlength} \
    --output ${read_alias}_f${quality_level}.fastq
    """
}