#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SEGMENTATION_FASTSEG } from '../../../../../modules/nf-scil/segmentation/fastseg/main.nf'

workflow test_segmentation_fastseg {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['fastseg']['image'], checkIfExists: true)
    ]

    SEGMENTATION_FASTSEG ( input )
}
