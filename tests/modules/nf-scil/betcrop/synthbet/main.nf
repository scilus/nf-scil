#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BETCROP_SYNTHBET } from '../../../../../modules/nf-scil/betcrop/synthbet/main.nf'

workflow test_betcrop_synthbet {

    input = [
        [ id:'test', single_end:false ], // meta map
        file("/workspaces/nf-scil/.test_data/heavy/anat/anat_image.nii.gz", checkIfExists: true),
        file("/workspaces/nf-scil/.test_data/heavy/freesurfer/license.txt", checkIfExists: true)
    ]

    BETCROP_SYNTHBET ( input )
}
