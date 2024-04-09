#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include { REGISTRATION_TRACTOGRAM } from '../../../../../modules/nf-scil/registration/tractogram/main.nf'

workflow test_registration_tractogram {

    input_fetch = Channel.from( [ "bundles.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/bundle_all_1mm.nii.gz"),
            file("${test_data_directory}/affine.txt"),
            file("${test_data_directory}/fibercup_atlas/subj_1/"),
            [],
            []
    ]}

    REGISTRATION_BUNDLEREGISTRATION ( input )
}
