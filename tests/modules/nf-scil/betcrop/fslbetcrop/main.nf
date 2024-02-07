#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BETCROP_FSLBETCROP } from '../../../../../modules/nf-scil/betcrop/fslbetcrop/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'

workflow test_betcrop_fslbetcrop_dwi {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['betcrop']['fslbetcrop']['dwi'], checkIfExists: true),
        file(params.test_data['betcrop']['fslbetcrop']['bval'], checkIfExists: true),
        file(params.test_data['betcrop']['fslbetcrop']['bvec'], checkIfExists: true)
    ]

    BETCROP_FSLBETCROP ( input )
}

workflow test_betcrop_fslbetcrop_t1 {

    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.test_betcrop_fslbetcrop_t1" )
    
    input = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ], // meta map
        file("${test_data_directory}/t1.nii.gz"),
        [], 
        [],
        file("${test_data_directory}/t1_template.nii.gz"),
        file("${test_data_directory}/t1_brain_probability_map.nii.gz")

    ]}

    BETCROP_FSLBETCROP ( input )
}