#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SEGMENTATION_FSRECONALL } from '../../../../../modules/nf-scil/segmentation/fsreconall/main.nf'
include { SEGMENTATION_FSRECONALLDEBUG } from '../../../../../modules/nf-scil/segmentation/fsreconalldebug/main.nf'

// Too long, we don't test.
// To test locally, uncomment the real test below!

workflow test_segmentation_fsreconall {
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['fsreconall']['anat'], checkIfExists: true),
        file(params.test_data['segmentation']['fsreconall']['license'], checkIfExists: true)
    ]

    // Hiding the real test because it is too long.
    // SEGMENTATION_FSRECONALL ( input )
    SEGMENTATION_FSRECONALLDEBUG ( input )

}
