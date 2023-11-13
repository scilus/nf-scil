#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONSTRUCTION_FODF } from '../../../../../modules/nf-scil/reconstruction/fodf/main.nf'

workflow test_reconstruction_fodf {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    RECONSTRUCTION_FODF ( input )
}

workflow test_reconstruction_fodf_with_fodf_shells {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    RECONSTRUCTION_FODF ( input )
}