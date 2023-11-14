#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_DIFFUSIVITYPRIORS as MEAN_PRIORS} from '../../../../../modules/nf-scil/reconst/diffusivitypriors/main.nf'
include { RECONST_DIFFUSIVITYPRIORS as COMPUTE_PRIORS} from '../../../../../modules/nf-scil/reconst/diffusivitypriors/main.nf'


workflow test_reconst_diffusivitypriors {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['diffusivitypriors']['fa'], checkIfExists: true),
        file(params.test_data['reconst']['diffusivitypriors']['md'], checkIfExists: true),
        file(params.test_data['reconst']['diffusivitypriors']['ad'], checkIfExists: true),
        file(params.test_data['reconst']['diffusivitypriors']['priors'], checkIfExists: true)
    ]

    MEAN_PRIORS ( input )
}

workflow test_reconst_diffusivitypriors {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['diffusivitypriors']['fa'], checkIfExists: true),
        file(params.test_data['reconst']['diffusivitypriors']['md'], checkIfExists: true),
        file(params.test_data['reconst']['diffusivitypriors']['ad'], checkIfExists: true)
    ]

    COMPUTE_PRIORS ( input )
}
