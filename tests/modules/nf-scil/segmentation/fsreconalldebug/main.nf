#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SEGMENTATION_FSRECONALLDEBUG } from '../../../../../modules/nf-scil/segmentation/fsreconalldebug/main.nf'

workflow test_segmentation_fsreconalldebug {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['fsreconall']['anat'], checkIfExists: true),
        file(params.test_data['segmentation']['fsreconall']['license'], checkIfExists: true)
    ]

    SEGMENTATION_FSRECONALLDEBUG ( input )
}
