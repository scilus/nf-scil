#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../load_test_data/main'
include { REGISTRATION   } from '../../../../subworkflows/nf-scil/registration/main'

workflow test_register_anattodwi_antsregistration {
    
    input_fetch = Channel.from( [ "processing.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    ch_image = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ],
            file("${test_data_directory}/mni_masked_2x2x2.nii.gz")]}
    ch_ref = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ],
            file("${test_data_directory}/b0_mean.nii.gz")]}
    ch_metric = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ],
            file("${test_data_directory}/fa.nii.gz")]}
    ch_mask = []

    REGISTRATION ( ch_image, ch_ref, ch_metric, ch_mask )
}

workflow test_register_anattodwi_syn {

    input_fetch = Channel.from( [ "processing.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    ch_image = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ],
            file("${test_data_directory}/mni_masked_2x2x2.nii.gz")]}
    ch_ref = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ],
            file("${test_data_directory}/b0_mean.nii.gz")]}
    ch_metric = []
    ch_mask = []

    REGISTRATION ( ch_image, ch_ref, ch_metric, ch_mask )
}
