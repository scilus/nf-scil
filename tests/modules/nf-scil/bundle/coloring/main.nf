#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BUNDLE_COLORING } from '../../../../../modules/nf-scil/bundle/coloring/main.nf'

workflow test_bundle_coloring {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    BUNDLE_COLORING ( input )
}
