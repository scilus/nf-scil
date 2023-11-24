#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { DENOISING_MPPCA } from '../../../../../modules/nf-scil/denoising/mppca/main.nf'

workflow test_denoising_mppca {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['denoising']['mppca']['dwi'], checkIfExists: true)
    ]

    DENOISING_MPPCA ( input )
}
