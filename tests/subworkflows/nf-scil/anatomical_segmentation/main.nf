#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { ANATOMICAL_SEGMENTATION } from '../../../../subworkflows/nf-scil//main.nf'

workflow test_anatomical_segmentation_fslfast {
    
    ch_image = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['fastseg']['image'], checkIfExists: true)
    ]
    ch_freesurferseg = []


    ANATOMICAL_SEGMENTATION ( ch_image, ch_freesurferseg )
}
