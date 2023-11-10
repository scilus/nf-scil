#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { TRACKING_PFTTRACKING } from '../../../../../modules/nf-scil/tracking/pfttracking/main.nf'

workflow test_tracking_pfttracking {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['betcrop']['cropvolume']['fodf'], checkIfExists: true),
        file(params.test_data['betcrop']['fslbetcrop']['seed'], checkIfExists: true),
        file(params.test_data['betcrop']['cropvolume']['include'], checkIfExists: true),
        file(params.test_data['betcrop']['cropvolume']['exclude'], checkIfExists: true)
    ]

    TRACKING_PFTTRACKING ( input )
}
