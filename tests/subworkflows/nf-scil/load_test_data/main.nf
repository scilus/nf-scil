#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../subworkflows/nf-scil/load_test_data/main.nf'

workflow test_load_test_data {

    input = Channel.from( [ "bids_json.zip", "plot.zip", "stats.zip" ] )

    LOAD_TEST_DATA ( input, "test.load-test-data" )
}
