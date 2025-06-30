def MakeDirectory(outdir){
    """
    mkdir -p ${outdir}
    """
}

def QCReads(outdir, input_type, reads){
    """
    NanoPlot --only-report \
    -o ${outdir} \
    --${input_type} \
    ${reads} 
    """
}

def SortBam(reads, output) {
    """
    samtools sort -o ${output} ${reads}
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