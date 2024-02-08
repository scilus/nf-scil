#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_IHMT } from '../../../../../modules/nf-scil/reconst/ihmt/main.nf'

workflow test_reconst_ihmt {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    RECONST_IHMT ( input )
}
