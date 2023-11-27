#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { 
    TRACKING_PFTTRACKING as WM_TRACKING;
    TRACKING_PFTTRACKING as FA_TRACKING;
    TRACKING_PFTTRACKING as INTERFACE_TRACKING; } from '../../../../../modules/nf-scil/tracking/pfttracking/main.nf'

workflow test_tracking_pfttracking_wm {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['tracking']['pfttracking']['wm'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['gm'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['csf'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['fodf'], checkIfExists: true),
        []
    ]

    WM_TRACKING ( input )
}


workflow test_tracking_pfttracking_fa {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['tracking']['pfttracking']['wm'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['gm'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['csf'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['fodf'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['fa'], checkIfExists: true)
    ]

    FA_TRACKING ( input )
}


workflow test_tracking_pfttracking_interface {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['tracking']['pfttracking']['wm'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['gm'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['csf'], checkIfExists: true),
        file(params.test_data['tracking']['pfttracking']['fodf'], checkIfExists: true),
        []
    ]

    INTERFACE_TRACKING ( input )
}
