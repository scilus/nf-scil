#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BETCROP_ANTSBET } from '../../../../../modules/nf-scil/betcrop/antsbet/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'

workflow test_betcrop_antsbet {

    input_fetch = Channel.from( [ "antsbet.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.test_betcrop_antsbet" )
    
    input = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ], // meta map
        file("${test_data_directory}/t1.nii.gz"),
        file("${test_data_directory}/t1_template.nii.gz"),
        file("${test_data_directory}/t1_brain_probability_map.nii.gz")

    ]}

    BETCROP_ANTSBET ( input )
}
