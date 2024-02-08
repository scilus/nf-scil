#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SEGMENTATION_FSLFIRST } from '../../../../../modules/nf-scil/segmentation/fslfirst/main.nf'

workflow test_segmentation_fslfirst {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['fslfirst']['image'], checkIfExists: true)
    ]

    SEGMENTATION_FSLFIRST ( input )
}
