#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include {
    IMAGE_RESAMPLE as IMAGE_RESAMPLE_VOXSIZE;
    IMAGE_RESAMPLE as IMAGE_RESAMPLE_VOLSIZE; } from '../../../../../modules/nf-scil/image/resample/main.nf'

workflow test_image_resample_voxsize {

    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_voxsize = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/fa.nii.gz")
    ]}

    IMAGE_RESAMPLE_VOXSIZE ( input_voxsize )
}

workflow test_image_resample_volsize {

    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_volsize = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/fa.nii.gz")
    ]}

    IMAGE_RESAMPLE_VOLSIZE ( input_volsize )
}
