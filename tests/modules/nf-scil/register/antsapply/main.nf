#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include { REGISTER_ANTSAPPLY } from '../../../../../modules/nf-scil/register/antsapply/main.nf'

workflow test_register_antsapply {

    input_fetch = Channel.from( [ "processing.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_apply = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec")
    ]}

    REGISTER_ANTSAPPLY ( input_apply )
}
