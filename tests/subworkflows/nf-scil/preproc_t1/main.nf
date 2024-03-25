#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_T1 } from '../../../../subworkflows/nf-scil//main.nf'

workflow test_preproc_t1 {

    ch_image = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['image'], checkIfExists: true)
    ]
    ch_template = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['template'], checkIfExists: true)
    ]
    ch_probability_map = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['probability_map'], checkIfExists: true)
    ]

    PREPROC_T1 ( ch_image, ch_template, ch_probability_map )
}
