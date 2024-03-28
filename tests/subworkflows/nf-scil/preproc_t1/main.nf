#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_T1 } from '../../../../subworkflows/nf-scil/preproc_t1/main.nf'
include { LOAD_TEST_DATA } from '../../../../subworkflows/nf-scil/load_test_data/main.nf'

workflow test_preproc_t1 {

    input_fetch = Channel.from( [ "antsbet.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.test_preproc_t1" )

    ch_image = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ],
        file("${test_data_directory}/t1_unaligned.nii.gz"),
        []
    ]}
    ch_template = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ],
        file("${test_data_directory}/t1_template.nii.gz")
    ]}
        ch_probability_map = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ],
        file("${test_data_directory}/t1_brain_probability_map.nii.gz")
    ]}
    PREPROC_T1 ( ch_image, ch_template, ch_probability_map )
}
