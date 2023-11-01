#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_N4 } from '../../../../../modules/nf-scil/preproc/n4/main.nf'

workflow test_preproc_n4 {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['n4']['dwi'], checkIfExists: true)
        file(params.test_data['preproc']['n4']['b0'], checkIfExists: true)
        file(params.test_data['preproc']['n4']['b0_mask'], checkIfExists: true)
    ]

    PREPROC_N4 ( input )
}
