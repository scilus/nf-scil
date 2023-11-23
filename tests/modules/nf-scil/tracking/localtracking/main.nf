#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { TRACKING_LOCALTRACKING } from '../../../../../modules/nf-scil/tracking/localtracking/main.nf'

workflow test_tracking_localtracking {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['tracking']['localtracking']['fodf'], checkIfExists: true)
        file(params.test_data['tracking']['localtracking']['seed'], checkIfExists: true)
        file(params.test_data['tracking']['localtracking']['tracking_mask'], checkIfExists: true)
    ]

    TRACKING_LOCALTRACKING ( input )
}
