#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include { BETCROP_SYNTHBET } from '../../../../../modules/nf-scil/betcrop/synthbet/main.nf'

workflow test_betcrop_synthbet {

    input_fetch = Channel.from( [ "freesurfer.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ], // meta map
        file("${test_data_directory}/anat_image.nii.gz"),
        []
    ]}

    BETCROP_SYNTHBET ( input )
}