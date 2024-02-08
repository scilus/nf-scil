#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BUNDLE_RECOGNIZE } from '../../../../../modules/nf-scil/bundle/recognize/main.nf'

workflow test_bundle_recognize {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    BUNDLE_RECOGNIZE ( input )
}
