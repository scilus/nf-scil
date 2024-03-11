#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'
include { REGISTRATION_ANTS } from '../../../../../modules/nf-scil/registration/ants/main.nf'

workflow test_registration_ants_quick {

    input_fetch = Channel.from( [ "others.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.test_registration_ants_quick" )
    
    input = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ],
            file("${test_data_directory}/t1_crop.nii.gz"),
            file("${test_data_directory}/t1_resample.nii.gz"),
            []
    ]}

    REGISTRATION_ANTS ( input )
}
workflow test_registration_ants_option {

    input_fetch = Channel.from( [ "others.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.test_registration_ants_option" )
    
    input = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ],
            file("${test_data_directory}/t1_crop.nii.gz"),
            file("${test_data_directory}/t1_resample.nii.gz"),
            []
    ]}

    REGISTRATION_ANTS ( input )
}