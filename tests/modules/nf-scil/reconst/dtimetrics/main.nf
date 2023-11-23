#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_DTIMETRICS } from '../../../../../modules/nf-scil/reconst/dtimetrics/main.nf'

workflow test_reconst_dtimetrics {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['dtimetrics']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['dtimetrics']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['dtimetrics']['bvec'], checkIfExists: true),
        []
    ]

    RECONST_DTIMETRICS ( input )
}

workflow test_reconst_dtimetrics_with_b0mask {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['dtimetrics']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['dtimetrics']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['dtimetrics']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['dtimetrics']['b0mask'], checkIfExists: true)
    ]

    RECONST_DTIMETRICS ( input )
}