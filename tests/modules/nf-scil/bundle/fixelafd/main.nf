#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BUNDLE_FIXELAFD } from '../../../../../modules/nf-scil/bundle/fixelafd/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

workflow test_bundle_fixelafd {
    input_fetch = Channel.from( [ "processing.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/tracking.trk"),
            file("${test_data_directory}/fodf_descoteaux07.nii.gz")
    ]}

    BUNDLE_FIXELAFD ( input )
}
