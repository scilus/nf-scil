#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BUNDLE_RECOGNIZE } from '../../../../../modules/nf-scil/bundle/recognize/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'

workflow test_bundle_recognize {

    input_fetch = Channel.from( [ "bundles.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/bundle_all_1mm.trk"),
            file("${test_data_directory}/affine.txt"),
            file("${test_data_directory}/config.json"),
            file("${test_data_directory}/fibercup_atlas/")
    ]}

    BUNDLE_RECOGNIZE ( input )
}
