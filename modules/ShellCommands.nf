def SortBam(reads, outfile_name) {
    """
    $workflow.projectDir/pipeline_scripts/SortBam.sh \
    --reads ${reads} \
    --outfile_name ${outfile_name}
    """
}


// bowtie 2
def BuildBowtieRefIndex(reference) {
    """
    # Build bowtie2 index
    bowtie2-build ${reference} "ref_index"
    """
}

def AlignWithBowtie2(reads, output) {
    """
    # Align reads
    bowtie2 -x "ref_index" \
    -U ${reads} \
    -S ${output} \
    --very-sensitive-local    
    """
}

// minimap2
def AlignWithMinimap2(k, w, reference, reads, output) {
    """
    minimap2 -k ${k} -w ${w} -ax sr \
    ${reference} ${reads} > ${output}    
    """
}