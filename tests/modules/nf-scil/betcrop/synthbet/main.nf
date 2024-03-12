#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BETCROP_SYNTHBET } from '../../../../../modules/nf-scil/betcrop/synthbet/main.nf'

workflow test_betcrop_synthbet {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['betcrop']['synthbet']['t1'], checkIfExists: true),
        file(params.test_data['betcrop']['synthbet']['license'], checkIfExists: true)
    ]

    BETCROP_SYNTHBET ( input )
}
