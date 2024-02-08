#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BUNDLE_FIXELAFD } from '../../../../../modules/nf-scil/bundle/fixelafd/main.nf'

workflow test_bundle_fixelafd {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    BUNDLE_FIXELAFD ( input )
}
