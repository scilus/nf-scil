#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include { RECONST_MEANFRF } from '../../../../../modules/nf-scil/reconst/meanfrf/main.nf'

workflow test_reconst_meanfrf {

    input_fetch = Channel.from( [ "processing.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_mfrf = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            file("${test_data_directory}/frf.txt")
    ]}

    RECONST_MEANFRF ( input_mfrf )
}
