#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_FRF } from '../../../../../modules/nf-scil/reconst/frf/main.nf'

workflow test_reconst_frf {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['mask'], checkIfExists: true)
    ]

    RECONST_FRF ( input )
}

workflow test_reconst_frf_nomask {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        []
    ]

    RECONST_FRF ( input )
}

workflow test_reconst_frf_set_frf {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['mask'], checkIfExists: true)
    ]

    RECONST_FRF ( input )
}

workflow test_reconst_frf_set_frf_nomask {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        []
    ]

    RECONST_FRF ( input )
}