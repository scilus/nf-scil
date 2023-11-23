#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_GIBBS } from '../../../../../modules/nf-scil/preproc/gibbs/main.nf'

workflow test_preproc_gibbs {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['n4']['dwi'], checkIfExists: true)
    ]

    PREPROC_GIBBS ( input )
}
