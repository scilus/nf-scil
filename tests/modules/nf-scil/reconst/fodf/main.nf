#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_FODF } from '../../../../../modules/nf-scil/reconst/fodf/main.nf'

workflow test_reconst_fodf {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    RECONST_FODF ( input )
}

workflow test_reconst_fodf_with_fodf_shells {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    RECONST_FODF ( input )
}