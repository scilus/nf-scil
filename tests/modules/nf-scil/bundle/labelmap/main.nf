#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BUNDLE_LABEL_AND_DISTANCE_MAPS } from '../../../../../modules/nf-scil/bundle/labelmap/main.nf'

workflow test_bundle_labelmap {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['bundlename']['centroidname'], checkIfExists: true)
    ]

    BUNDLE_LABEL_AND_DISTANCE_MAPS ( input )
}
