#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPROC_NORMALIZE } from '../../../../../modules/nf-scil/preproc/normalize/main.nf'

workflow test_preproc_normalize {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['normalize']['dwi'], checkIfExists: true),
        file(params.test_data['preproc']['normalize']['mask'], checkIfExists: true),
        file(params.test_data['preproc']['normalize']['bval'], checkIfExists: true),
        file(params.test_data['preproc']['normalize']['bvec'], checkIfExists: true)
    ]

    PREPROC_NORMALIZE ( input )
}

workflow test_preproc_normalize_with_dti_shells {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['preproc']['normalize']['dwi'], checkIfExists: true),
        file(params.test_data['preproc']['normalize']['mask'], checkIfExists: true),
        file(params.test_data['preproc']['normalize']['bval'], checkIfExists: true),
        file(params.test_data['preproc']['normalize']['bvec'], checkIfExists: true)
    ]

    dti_shell = '0 300 1000'

    PREPROC_NORMALIZE ( input, dti_shell )
}
