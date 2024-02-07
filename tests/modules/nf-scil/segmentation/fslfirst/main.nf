#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

//include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main.nf'
include { SEGMENTATION_FSLFIRST } from '../../../../../modules/nf-scil/segmentation/fslfirst/main.nf'

workflow test_segmentation_fslfirst {
    /*
    input_fetch = Channel.from( [ "others.zip" ] )

    LOAD_TEST_DATA ( input_fetch, "test.load-test-data" )


    input_fslfirst = LOAD_TEST_DATA.out.test_data_directory
            .map{ test_data_directory -> [
            [ id:'test', single_end:false ], // meta map
            file("${test_data_directory}/anat_image.nii.gz")
    ]}
    */
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['fslfirst']['image'], checkIfExists: true)
    ]

    SEGMENTATION_FSLFIRST ( input )
}
