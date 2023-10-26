#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SCILPY_CROPVOLUME } from '../../../../../modules/nf-scil/scilpy/cropvolume/main.nf'

workflow test_scilpy_cropvolume {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['scilpy']['cropvolume']['image'], checkIfExists: true),
        file(params.test_data['scilpy']['cropvolume']['mask'], checkIfExists: true)
    ]

    SCILPY_CROPVOLUME ( input )
}
