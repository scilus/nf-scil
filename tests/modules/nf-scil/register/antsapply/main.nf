#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { REGISTER_ANTSAPPLY } from '../../../../../modules/nf-scil/register/antsapply/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

workflow test_register_antsapply {

    input_fetch = Channel.from( [ "register.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_apply = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/mni_masked_2x2x2.nii.gz"),
            file("${test_data_directory}/b0.nii.gz"),
            [file("${test_data_directory}/output1Warp.nii.gz"),
            file("${test_data_directory}/output0GenericAffine.mat")]
    ]}

    REGISTER_ANTSAPPLY ( input_apply )
}
