#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { IO_READBIDS } from '../../../../../modules/nf-scil/io/readbids/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'

workflow test_io_readbids {

    input = file(params.test_data['io']['readbids']['bids_dir'], checkIfExists: true)

    IO_READBIDS ( input, [], [] )
}
