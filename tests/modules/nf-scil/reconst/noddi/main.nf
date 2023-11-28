#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

include { 
    RECONST_NODDI as COMPUTE_KERNELS;
    RECONST_NODDI as COMPUTE_METRICS} from '../../../../../modules/nf-scil/reconst/noddi/main.nf'

workflow test_reconst_noddi_save_kernels {

    input_fetch = Channel.from( [ "commit_amico.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_noddi = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            file("${test_data_directory}/mask.nii.gz"),
            []
    ]}

    COMPUTE_KERNELS ( input_noddi )
}

workflow test_reconst_noddi_save_kernels_no_mask {

    input_fetch = Channel.from( [ "commit_amico.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_noddi = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            [], []
    ]}

    COMPUTE_KERNELS ( input_noddi )
}


workflow test_reconst_noddi_load_kernels_mask {

    input_fetch = Channel.from( [ "commit_amico.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_noddi = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            file("${test_data_directory}/mask.nii.gz"),
            file("${test_data_directory}/kernels")
    ]}

    COMPUTE_METRICS ( input_noddi )
}


workflow test_reconst_noddi_load_kernels_no_mask {

    input_fetch = Channel.from( [ "commit_amico.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_noddi = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/dwi.nii.gz"),
            file("${test_data_directory}/dwi.bval"),
            file("${test_data_directory}/dwi.bvec"),
            [],
            file("${test_data_directory}/kernels"
    ]}

    COMPUTE_METRICS ( input_noddi )
}
