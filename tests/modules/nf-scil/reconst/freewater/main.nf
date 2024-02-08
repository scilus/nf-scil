#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_FREEWATER } from '../../../../../modules/nf-scil/reconst/freewater/main.nf'

workflow test_reconst_freewater {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    RECONST_FREEWATER ( input )
}
