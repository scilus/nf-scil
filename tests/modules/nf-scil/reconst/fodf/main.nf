#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_FODF } from '../../../../../modules/nf-scil/reconst/fodf/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

workflow test_reconst_fodf {

    input_fetch = Channel.from( [ "processing.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_no_shell = LOAD_TEST_DATA.out.test_data_directory
        .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            file("${test_data_directory}/cc.nii.gz"),
            file("${test_data_directory}/fa.nii.gz"),
            file("${test_data_directory}/md.nii.gz"),
            file("${test_data_directory}/frf.txt")
        ]}

    RECONST_FODF ( input_no_shell )
}

workflow test_reconst_fodf_with_fodf_shells {

    input_fetch = Channel.from( [ "processing.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_shells = LOAD_TEST_DATA.out.test_data_directory
        .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            file("${test_data_directory}/cc.nii.gz"),
            file("${test_data_directory}/fa.nii.gz"),
            file("${test_data_directory}/md.nii.gz"),
            file("${test_data_directory}/frf.txt")
        ]}

    RECONST_FODF ( input_shells )
}

workflow test_reconst_fodf_no_mask {

    input_fetch = Channel.from( [ "processing.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_no_mask = LOAD_TEST_DATA.out.test_data_directory
        .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            [],
            file("${test_data_directory}/fa.nii.gz"),
            file("${test_data_directory}/md.nii.gz"),
            file("${test_data_directory}/frf.txt")
        ]}

    RECONST_FODF ( input_no_mask )
}
