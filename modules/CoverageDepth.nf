include { 
    DetermineCoverage;
    } from "./ShellCommands.nf"

process CoverageDepth {
    tag "Getting Read Depth ${reads}"

    input:
        tuple(
            path(reads), 
            val(read_alias)
            val(reference), 
        )

    output:
        path("${read_alias}_coverage_report.csv")

    publishDir "${params.outdir}/${read_alias}", mode: 'copy'

    script:
    """
        ${DetermineCoverage("${reads}", "${read_alias}")}
    """
}