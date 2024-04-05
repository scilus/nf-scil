#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SEGMENTATION_FREESURFERSEG } from '../../../../../modules/nf-scil/segmentation/freesurferseg/main.nf'

workflow test_segmentation_freesurferseg {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['freesurferseg']['aparc_aseg'], checkIfExists: true),
        file(params.test_data['segmentation']['freesurferseg']['wmparc'], checkIfExists: true)
    ]

    SEGMENTATION_FREESURFERSEG ( input )
}
