#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { IO_READBIDS } from '../../../../../modules/nf-scil/io/readbids/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'

workflow test_io_readbids {

    input_fetch = Channel.from( [ "i_bids" ] )  // pas sûre
    LOAD_TEST_DATA ( input_fetch, "test.test_io_readbids" )

    input = LOAD_TEST_DATA.out.test_data_directory
        .map{ test_data_directory -> file("${test_data_directory}/i_bids", checkIfExists: true)}

    IO_READBIDS ( input, [], [] )
}
