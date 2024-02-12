#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RECONST_FODFMETRICS } from '../../../../../modules/nf-scil/reconst/fodfmetrics/main.nf'
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'

workflow test_reconst_fodf_metrics {

    input_fetch = Channel.from( [ "processing.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_fodf_metrics = LOAD_TEST_DATA.out.test_data_directory
        .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/fodf.nii.gz"),
            [],
            file("${test_data_directory}/fa.nii.gz"),
            file("${test_data_directory}/md.nii.gz"),
        ]}

    RECONST_FODFMETRICS ( input_fodf_metrics )
}
