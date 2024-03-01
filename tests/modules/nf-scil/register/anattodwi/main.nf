#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'
include { REGISTER_ANATTODWI } from '../../../../../modules/nf-scil/register/anattodwi/main.nf'

workflow test_register_anattodwi {

    input_fetch = Channel.from( [ "processing.zip" ] )
    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_reg = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ],
            file("${test_data_directory}/t1.nii.gz"),
            file("${test_data_directory}/b0_mean.nii.gz"),
            file("${test_data_directory}/fa.nii.gz")
    ]}

    REGISTER_ANATTODWI ( input_reg )
}
