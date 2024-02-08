#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BUNDLE_COLORING } from '../../../../../modules/nf-scil/bundle/coloring/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'



workflow test_bundle_coloring {

    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA( input_fetch, "test.load-test-data" )

    input = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/IFGWM.trk"),

  ] }

    BUNDLE_COLORING ( input )
}
