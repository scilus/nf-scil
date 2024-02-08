#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SEGMENTATION_FSRECONALL } from '../../../../../modules/nf-scil/segmentation/fsreconall/main.nf'

workflow test_segmentation_fsreconall {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    SEGMENTATION_FSRECONALL ( input )
}
