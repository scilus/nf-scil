#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

include {
    RECONST_FREEWATER as RECONST_FREEWATER_KERNELS;
    RECONST_FREEWATER as RECONST_FREEWATER_METRICS} from '../../../../../modules/nf-scil/reconst/freewater/main.nf'

workflow test_reconst_freewater_save_kernels {

    input_fetch = Channel.from( [ "commit_amico.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_freewater = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            file("${test_data_directory}/mask.nii.gz"),
            []
    ]}

    RECONST_FREEWATER_KERNELS ( input_freewater )
}

workflow test_reconst_freewater_save_kernels_no_mask {

    input_fetch = Channel.from( [ "commit_amico.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_freewater = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            [], []
    ]}

    RECONST_FREEWATER_KERNELS ( input_freewater )
}
