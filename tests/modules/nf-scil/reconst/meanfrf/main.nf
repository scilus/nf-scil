#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_MEANFRF } from '../../../../../modules/nf-scil/reconst/meanfrf/main.nf'

workflow test_reconst_meanfrf {
    
    input = [
        file(params.test_data['reconst']['meanfrf']['frf_list'], checkIfExists: true)
    ]

    RECONST_MEANFRF ( input )
}
