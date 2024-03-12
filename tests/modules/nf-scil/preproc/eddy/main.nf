#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_EDDY } from '../../../../../modules/nf-scil/preproc/eddy/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'

workflow test_preproc_eddy {

input_fetch = Channel.from( [ "topup_eddy.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.test_preproc_topup" )

    input = LOAD_TEST_DATA.out.test_data_directory
        .map{ test_data_directory -> [
        [ id:'test', single_end:false ], // meta map
        file("${test_data_directory}/sub-01_dir-AP_dwi.nii.gz", checkIfExists: true),
        file("${test_data_directory}/sub-01_dir-AP_dwi.bval", checkIfExists: true),
        file("${test_data_directory}/sub-01_dir-AP_dwi.bvec", checkIfExists: true),
        file("${test_data_directory}/sub-01_dir-PA_dwi.nii.gz", checkIfExists: true),
        file("${test_data_directory}/sub-01_dir-PA_dwi.bval", checkIfExists: true),
        file("${test_data_directory}/sub-01_dir-PA_dwi.bvec", checkIfExists: true),
        file("${test_data_directory}/sub-01__corrected_b0s.nii.gz", checkIfExists: true),
        file("${test_data_directory}/topup_results_fieldcoef.nii.gz", checkIfExists: true),
        file("${test_data_directory}/topup_results_movpar.txt", checkIfExists: true)
    ]}

    PREPROC_EDDY ( input )
}
