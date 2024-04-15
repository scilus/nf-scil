#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../subworkflows/nf-scil/load_test_data/main.nf'
include { PREPROC_DWI } from '../../../../subworkflows/nf-scil/preproc_dwi/main.nf'


workflow test_preproc_dwi_norev {

    input_fetch = Channel.from( [ "processing.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.test_preproc_t1" )

    ch_dwi = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ],
        file("${test_data_directory}/dwi.nii.gz"),
    ]}
    ch_bval_bvec = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ],
        file("${test_data_directory}/dwi.bval"),
        file("${test_data_directory}/dwi.bvec")
    ]}
    ch_rev_b0 = Channel.empty()
    PREPROC_DWI ( ch_dwi, ch_bval_bvec, ch_rev_b0 )
}


workflow test_preproc_dwi_rev {

    input_fetch = Channel.from( [ "processing.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.test_preproc_t1" )

    ch_dwi = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ],
        file("${test_data_directory}/dwi.nii.gz"),
    ]}
    ch_bval_bvec = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ],
        file("${test_data_directory}/dwi.bval"),
        file("${test_data_directory}/dwi.bvec")
    ]}
    ch_rev_b0 = LOAD_TEST_DATA.out.test_data_directory
    .map{ test_data_directory -> [
        [ id:'test', single_end:false ],
        file("${test_data_directory}/rev_b0.nii.gz") // **No reverse B0 in this folder for now**//
    ]}

    PREPROC_DWI ( ch_dwi, ch_bval_bvec, ch_rev_b0 )
}

