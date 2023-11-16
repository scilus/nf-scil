#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { IMAGE_RESAMPLE } from '../../../../../modules/nf-scil/image/resample/main.nf'

workflow test_image_resample {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['image']['resample']['image'], checkIfExists: true)
    ]

    IMAGE_RESAMPLE ( input )
}
