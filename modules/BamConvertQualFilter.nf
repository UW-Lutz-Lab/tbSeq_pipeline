include { Bam2FqQualLenFilter } from "./ShellCommands.nf"

process BamConvertQualFilter {
    tag "Converting ${reads.baseName} to Fastq"

    input:
        tuple(
            path(reads),
            val(read_alias),
            val(reference),
            val(min_quality_filter),
            val(max_quality_filter),
            val(minlength),
            val(maxlength)
        )

    output:
        tuple(
            path("${read_alias}_f${min_quality_filter}.fastq"),
            val(read_alias),
            val(reference)
        )

    script:
        Bam2FqQualLenFilter(
            reads,
            "${read_alias}_f${min_quality_filter}.fastq",
            min_quality_filter,
            max_quality_filter,
            minlength,
            maxlength
        )
}