#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { NFSCIL_VOLRESAMPLING } from '../../../../../modules/nf-scil/nfscil/volresampling/main.nf'

workflow test_nfscil_volresampling {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['nfscil']['volresampling']['image'], checkIfExists: true)
    ]

    NFSCIL_VOLRESAMPLING ( input )
}
