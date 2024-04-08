#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_N4 } from '../../../../../modules/nf-scil/preproc/n4/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'

workflow test_preproc_n4_dwi {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['n4']['dwi'], checkIfExists: true),
        file(params.test_data['preproc']['n4']['b0'], checkIfExists: true),
        file(params.test_data['preproc']['n4']['b0_mask'], checkIfExists: true)
    ]

    PREPROC_N4 ( input )
}

workflow test_preproc_n4_t1 {

    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.test_preproc_n4_t1" )

    input = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ], // meta map
        file("${test_data_directory}/t1.nii.gz"),
        [],
        []
    ]}

    PREPROC_N4 ( input )
}
