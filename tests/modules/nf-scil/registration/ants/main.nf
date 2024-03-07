#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { REGISTRATION_ANTS } from '../../../../../modules/nf-scil/registration/ants/main.nf'

workflow test_registration_ants {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    REGISTRATION_ANTS ( input )
}
