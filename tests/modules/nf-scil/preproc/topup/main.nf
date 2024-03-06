#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_TOPUP } from '../../../../../modules/nf-scil/preproc/topup/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'

workflow test_preproc_topup {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['topup']['dwi'], checkIfExists: true),
        file(params.test_data['preproc']['topup']['bval'], checkIfExists: true),
        file(params.test_data['preproc']['topup']['bvec'], checkIfExists: true),
        file(params.test_data['preproc']['topup']['b0'], checkIfExists: true),
        file(params.test_data['preproc']['topup']['rev_dwi'], checkIfExists: true),
        file(params.test_data['preproc']['topup']['rev_bval'], checkIfExists: true),
        file(params.test_data['preproc']['topup']['rev_bvec'], checkIfExists: true),
        file(params.test_data['preproc']['topup']['rev_b0'], checkIfExists: true)
    ]

    PREPROC_TOPUP ( input, [] )
}
