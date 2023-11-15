#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_FODF } from '../../../../../modules/nf-scil/reconst/fodf/main.nf'

workflow test_reconst_fodf {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['fodf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['b0_mask'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['fa'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['md'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['frf'], checkIfExists: true),   
    ]

    RECONST_FODF ( input )
}

workflow test_reconst_fodf_with_fodf_shells {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['fodf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['b0_mask'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['fa'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['md'], checkIfExists: true),
        file(params.test_data['reconst']['fodf']['frf'], checkIfExists: true),
    ]

    RECONST_FODF ( input )
}