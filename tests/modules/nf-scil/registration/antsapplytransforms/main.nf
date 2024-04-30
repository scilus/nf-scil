#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include {
    REGISTRATION_ANTSAPPLYTRANSFORMS as REGISTRATION_ANTSAPPLYTRANSFORMS_TEST;} from '../../../../../modules/nf-scil/registration/antsapplytransforms/main.nf'

workflow test_registration_applytransforms {

    input_fetch = Channel.from( [ "bst.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_test = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/fa.nii.gz"),
            file("${test_data_directory}/mask.nii.gz"),
            file("${test_data_directory}/output1InverseWarp.nii.gz")
            ]}

    REGISTRATION_ANTSAPPLYTRANSFORMS_TEST ( input_test )
}
