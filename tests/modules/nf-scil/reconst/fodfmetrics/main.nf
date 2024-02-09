#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_FODFMETRICS } from '../../../../../modules/nf-scil/reconst/fodfmetrics/main.nf'

workflow test_reconst_fodfmetrics {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    RECONST_FODFMETRICS ( input )
}
