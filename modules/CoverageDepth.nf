process CoverageDepth {
    tag "Getting Read Depth ${reads}"

    input:
    path reads
    val read_alias

    output:
    path "${read_alias}_coverage_report.csv"

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
    samtools depth -a ${reads} | awk '{OFS=","; print \$1, \$2, \$3}' > ${read_alias}_coverage_report.csv
    """
}