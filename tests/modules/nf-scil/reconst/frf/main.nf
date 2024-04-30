#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_FRF } from '../../../../../modules/nf-scil/reconst/frf/main.nf'

workflow test_reconst_ssst_frf {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['mask'], checkIfExists: true),
        [],
        [],
        [],
        []
    ]

    RECONST_FRF ( input )
}

workflow test_reconst_ssst_frf_nomask {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        [],
        [],
        [],
        [],
        []
    ]

    RECONST_FRF ( input )
}

workflow test_reconst_ssst_frf_set_frf {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['mask'], checkIfExists: true),
        [],
        [],
        [],
        []
    ]

    RECONST_FRF ( input )
}

workflow test_reconst_ssst_frf_set_frf_nomask {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        [],
        [],
        [],
        [],
        []
    ]

    RECONST_FRF ( input )
}

workflow test_reconst_msmt_frf { // What data do I take here?

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['mask'], checkIfExists: true),
        [],
        [],
        [],
        []
    ]

    RECONST_FRF ( input )
}

workflow test_reconst_msmt_frf_set_frf { // What data do I take here?

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['reconst']['frf']['dwi'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bval'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['bvec'], checkIfExists: true),
        file(params.test_data['reconst']['frf']['mask'], checkIfExists: true),
        [],
        [],
        [],
        []
    ]

    RECONST_FRF ( input ) // We need to update scil_frf_set_diffusivities.py to take msmt FRFs. Change the configs accordingly after.
}
