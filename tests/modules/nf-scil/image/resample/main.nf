#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include { 
    IMAGE_RESAMPLE as VOXSIZE_RESAMPLE;
    IMAGE_RESAMPLE as VOLSIZE_RESAMPLE; } from '../../../../../modules/nf-scil/image/resample/main.nf'

workflow test_image_resample_voxsize {
    
    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_voxsize = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/fa.nii.gz")
    ]}

    VOXSIZE_RESAMPLE ( input_voxsize )
}

workflow test_image_resample_volsize {
    
    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )

    input_volsize = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/fa.nii.gz")
    ]}

    VOLSIZE_RESAMPLE ( input_volsize )
}