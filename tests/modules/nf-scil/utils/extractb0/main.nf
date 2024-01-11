#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    UTILS_EXTRACTB0 as UTILS_EXTRACTB0_MEAN;
    UTILS_EXTRACTB0 as UTILS_EXTRACTB0_ALL4D;
    UTILS_EXTRACTB0 as UTILS_EXTRACTB0_ALLSERIES;
    UTILS_EXTRACTB0 as UTILS_EXTRACTB0_CLUSTERMEAN;
    UTILS_EXTRACTB0 as UTILS_EXTRACTB0_CLUSTERFIRST} from '../../../../../modules/nf-scil/utils/extractb0/main.nf'

workflow test_utils_extractb0_mean {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['utils']['extractb0']['dwi'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bval'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bvec'], checkIfExists: true)
    ]

    UTILS_EXTRACTB0_MEAN ( input )
}

workflow test_utils_extractb0_all_4D {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['utils']['extractb0']['dwi'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bval'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bvec'], checkIfExists: true)
    ]

    UTILS_EXTRACTB0_ALL4D ( input )
}

workflow test_utils_extractb0_all_series {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['utils']['extractb0']['dwi'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bval'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bvec'], checkIfExists: true)
    ]

    UTILS_EXTRACTB0_ALLSERIES ( input )
}

workflow test_utils_extractb0_cluster_mean {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['utils']['extractb0']['dwi'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bval'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bvec'], checkIfExists: true)
    ]

    UTILS_EXTRACTB0_CLUSTERMEAN ( input )
}

workflow test_utils_extractb0_cluster_first {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['utils']['extractb0']['dwi'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bval'], checkIfExists: true),
        file(params.test_data['utils']['extractb0']['bvec'], checkIfExists: true)
    ]

    UTILS_EXTRACTB0_CLUSTERFIRST ( input )
}
