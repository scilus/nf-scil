#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SEGMENTATION_FSRECONALL } from '../../../../../modules/nf-scil/segmentation/fsreconall/main.nf'

workflow test_segmentation_fsreconall {

    # Too long, we don't test.
    # To test locally, uncomment the following lines:
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['fsreconall']['anat'], checkIfExists: true)
    ]

    SEGMENTATION_FSRECONALL ( input )

}
