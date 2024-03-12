#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include {
    TRACKING_LOCALTRACKING as TRACKING_WM;
    TRACKING_LOCALTRACKING as TRACKING_FA; } from '../../../../../modules/nf-scil/tracking/localtracking/main.nf'

workflow test_tracking_localtracking_wm {

    input_fetch = Channel.from( [ "tracking.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_wm = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/map_wm.nii.gz"),
            file("${test_data_directory}/fodf.nii.gz"),
            file("${test_data_directory}/fa.nii.gz")
    ]}

    TRACKING_WM ( input_wm )
}

workflow test_tracking_localtracking_fa {

    input_fetch = Channel.from( [ "tracking.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_fa = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/map_wm.nii.gz"),
            file("${test_data_directory}/fodf.nii.gz"),
            file("${test_data_directory}/fa.nii.gz")
    ]}

    TRACKING_FA ( input_fa )
}
