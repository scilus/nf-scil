#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BETCROP_ANTSBET } from '../../../../../modules/nf-scil/betcrop/antsbet/main.nf'

workflow test_betcrop_antsbet {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['betcrop']['antsbet']['t1'], checkIfExists: true),
        file(params.test_data['betcrop']['antsbet']['template'], checkIfExists: true),
        file(params.test_data['betcrop']['antsbet']['map'], checkIfExists: true)
    ]

    BETCROP_ANTSBET ( input )
}
