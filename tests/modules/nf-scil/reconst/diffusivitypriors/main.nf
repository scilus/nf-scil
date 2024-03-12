#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_DIFFUSIVITYPRIORS as RECONST_MEAN_PRIORS} from '../../../../../modules/nf-scil/reconst/diffusivitypriors/main.nf'
include { RECONST_DIFFUSIVITYPRIORS as RECONST_COMPUTE_PRIORS} from '../../../../../modules/nf-scil/reconst/diffusivitypriors/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

workflow test_reconst_diffusivitypriors_compute_priors {

    input_fetch = Channel.from( [ "commit_amico.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_priors = LOAD_TEST_DATA.out.test_data_directory
        .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/fa.nii.gz"),
            file("${test_data_directory}/md.nii.gz"),
            file("${test_data_directory}/ad.nii.gz"),
            []
        ]}

    RECONST_COMPUTE_PRIORS ( input_priors )
}

workflow test_reconst_diffusivitypriors_mean_priors {

    input = [
        [ id:'test', single_end:false ], // meta map
        [],[],[],
        params.test_data['reconst']['diffusivitypriors']['priors'].collect{ file(it, checkIfExists: true) }
    ]

    RECONST_MEAN_PRIORS ( input )
}


