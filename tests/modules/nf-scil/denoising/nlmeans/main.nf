#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { DENOISING_NLMEANS } from '../../../../../modules/nf-scil/denoising/nlmeans/main.nf'

workflow test_denoising_nlmeans {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['denoising']['nlmeans']['image'], checkIfExists: true),
        []
]

    DENOISING_NLMEANS ( input )
}


workflow test_denoising_nlmeans_with_mask {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['denoising']['nlmeans']['image'], checkIfExists: true),
        file(params.test_data['denoising']['nlmeans']['mask'], checkIfExists: true)
]

    DENOISING_NLMEANS ( input )
}