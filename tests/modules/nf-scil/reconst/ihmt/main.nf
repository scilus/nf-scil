#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

include { RECONST_IHMT } from '../../../../../modules/nf-scil/reconst/ihmt/main.nf'

workflow test_reconst_ihmt {

    input_fetch = Channel.from( [ "ihMT.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )
    
        input_ihmt = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            [file("${test_data_directory}/echo-1_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-altpn_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-altnp_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-pos_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-neg_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-mtoff_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-T1w_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-T1w_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-T1w_ihmt.nii.gz")],
            file("${test_data_directory}/mask_resample.nii.gz"),
            [file("${test_data_directory}/echo-1_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-1_acq-T1w_ihmt.nii.gz")],
            [],
            [],
            []
    ]}

    RECONST_IHMT ( input_ihmt )
}

workflow test_reconst_ihmt_no_mask {

    input_fetch = Channel.from( [ "ihMT.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )
    
        input_ihmt = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            [file("${test_data_directory}/echo-1_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-altpn_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-altnp_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-pos_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-neg_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-mtoff_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-T1w_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-T1w_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-T1w_ihmt.nii.gz")],
            [],
            [file("${test_data_directory}/echo-1_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-1_acq-T1w_ihmt.nii.gz")],
            [],
            [],
            []
    ]}

    RECONST_IHMT ( input_ihmt )
}


workflow test_reconst_ihmt_no_t1 {

    input_fetch = Channel.from( [ "ihMT.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )
    
        input_ihmt = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            [file("${test_data_directory}/echo-1_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-altpn_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-altnp_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-pos_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-neg_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-mtoff_ihmt.nii.gz")],
            [],
            file("${test_data_directory}/mask_resample.nii.gz"),
            [],
            [],
            [],
            []
    ]}

    RECONST_IHMT ( input_ihmt )
}

workflow test_reconst_ihmt_single_echo {

    input_fetch = Channel.from( [ "ihMT.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )
    
        input_ihmt = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/echo-1_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-1_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-1_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-1_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-1_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-1_acq-T1w_ihmt.nii.gz"),
            file("${test_data_directory}/mask_resample.nii.gz"),
            [file("${test_data_directory}/echo-1_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-1_acq-T1w_ihmt.nii.gz")],
            [],
            [],
            []
    ]}

    RECONST_IHMT ( input_ihmt )
}

workflow test_reconst_ihmt_acq_params {

    input_fetch = Channel.from( [ "ihMT.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )
    
        input_ihmt = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            [file("${test_data_directory}/echo-1_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-altpn_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-altpn_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-altnp_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-altnp_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-pos_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-pos_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-neg_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-neg_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-mtoff_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-mtoff_ihmt.nii.gz")],
            [file("${test_data_directory}/echo-1_acq-T1w_ihmt.nii.gz"),
            file("${test_data_directory}/echo-2_acq-T1w_ihmt.nii.gz"),
            file("${test_data_directory}/echo-3_acq-T1w_ihmt.nii.gz")],
            file("${test_data_directory}/mask_resample.nii.gz"),
            [],
            ["5", "15", "0.1", "0.01"],
            [],
            []
    ]}

    RECONST_IHMT ( input_ihmt )
}