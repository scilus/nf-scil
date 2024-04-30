#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BETCROP_CROPVOLUME } from '../../../../../modules/nf-scil/betcrop/cropvolume/main.nf'

workflow test_betcrop_cropvolume {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['betcrop']['cropvolume']['image'], checkIfExists: true),
        []
    ]

    BETCROP_CROPVOLUME ( input )
}

workflow test_betcrop_cropvolume_output_bbox {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['betcrop']['cropvolume']['image'], checkIfExists: true),
        []
    ]

    BETCROP_CROPVOLUME ( input )
}
