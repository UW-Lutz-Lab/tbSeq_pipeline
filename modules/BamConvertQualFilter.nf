// include { Bam2FqQualLenFilter } from "./ShellCommands.nf"

// process BamConvertQualFilter {
//     tag "Converting ${reads.baseName} to Fastq"

//     input:
//         tuple(
//             path reads,
//             val read_alias,
//             val reference,
//             val min_quality_filter,
//             val max_quality_filter,
//             val minlength,
//             val maxlength
//         ) 
//     // path reads
//     // // val reads
//     // val read_alias
//     // val reference
//     // val quality_level
//     // val minlength
//     // val maxlength

//     output:
//         tuple(
//             path "${read_alias}_f${quality_level}.fastq",
//             val read_alias,
//             val reference
//         )
//     // path "${read_alias}_f${quality_level}.fastq"
//     // val read_alias 
//     // val reference
//     // file "${reads.baseName}_aligned.sam"

//     // publishDir "${params.outdir}/${read_alias}", mode: 'copy'

//     script:
//         Bam2FqQualLenFilter(
//             reads,
//             "${read_alias}_f${min_quality_filter}.fastq",
//             min_quality_filter,
//             max_quality_filter,
//             minlength,
//             maxlength
//         )
//         // """
//         // $workflow.projectDir/pipeline_scripts/BamConvertQualFilter.sh \
//         // --quality_filter ${quality_level} \
//         // --reads ${reads} \
//         // --minlength ${minlength} \
//         // --maxlength ${maxlength} \
//         // --output ${read_alias}_f${quality_level}.fastq
//         // """
// }

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