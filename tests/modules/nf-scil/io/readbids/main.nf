#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { IO_READBIDS } from '../../../../../modules/nf-scil/io/readbids/main.nf'

workflow test_io_readbids {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    IO_READBIDS ( input )
}
