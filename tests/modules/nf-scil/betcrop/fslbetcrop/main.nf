#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BETCROP_FSLBETCROP } from '../../../../../modules/nf-scil/betcrop/fslbetcrop/main.nf'

workflow test_betcrop_fslbetcrop {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['betcrop']['fslbetcrop']['dwi'], checkIfExists: true),
        file(params.test_data['betcrop']['fslbetcrop']['bval'], checkIfExists: true),
        file(params.test_data['betcrop']['fslbetcrop']['bvec'], checkIfExists: true)
    ]

    BETCROP_FSLBETCROP ( input )
}
