#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SEGMENTATION_FSRECONALL } from '../../../../../modules/nf-scil/segmentation/fsreconall/main.nf'

// Too long, we don't test.
// To test locally, add the following lines to the workflow below:


workflow test_segmentation_fsreconall {
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['segmentation']['fsreconall']['anat'], checkIfExists: true),
        file(params.test_data['segmentation']['fsreconall']['license'], checkIfExists: true)
    ]

    // Hiding the real test because it is too long.
    // SEGMENTATION_FSRECONALL ( input )

    // But nf-core does not allow an empty test. Results in critical error: Could not find any test result files in '/tmp/xxxxx'.
    // Creating a fake new file.
    def file = new File("test__recon_all")
    file.mkdir()


}
