#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

include { RECONST_IHMT } from '../../../../../modules/nf-scil/reconst/ihmt/main.nf'

workflow test_reconst_ihmt {

    input_fetch = Channel.from( [ "ihMT.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )
    
    input_ihmt = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    RECONST_IHMT ( input_ihmt )
}
