// ** Importing modules from nf-scil ** //
include { SEGMENTATION_FASTSEG       } from '../../../modules/nf-scil/segmentation/fastseg/main'
include { SEGMENTATION_FREESURFERSEG } from '../../../modules/nf-scil/segmentation/freesurferseg/main'

workflow ANATOMICAL_SEGMENTATION {

    // ** Two input channels for the segmentation processes since they are using   ** //
    // ** different image files. Supplying an empty channel for the one that isn't ** //
    // ** relevant will make the workflow run the appropriate module.              ** //
    take:
        ch_image            // channel: [ val(meta), image ], optional
        ch_freesurferseg    // channel: [ val(meta), aparc_aseg, wmparc ], optional
        ch_lesions          // channel: [ val(meta), lesions ], optional

    main:

        ch_versions = Channel.empty()

        // ** FSL fast segmentation ** //
        // TODO: Add lesion mask
        SEGMENTATION_FASTSEG (
            ch_image
                .join(ch_lesions, remainder: true)
                .map{ it[0..1] + [it[2] ?: []] }
        )
        ch_versions = ch_versions.mix(SEGMENTATION_FASTSEG.out.versions.first())

        // ** Setting outputs ** //
        wm_mask = SEGMENTATION_FASTSEG.out.wm_mask
        gm_mask = SEGMENTATION_FASTSEG.out.gm_mask
        csf_mask = SEGMENTATION_FASTSEG.out.csf_mask
        wm_map = SEGMENTATION_FASTSEG.out.wm_map
        gm_map = SEGMENTATION_FASTSEG.out.gm_map
        csf_map = SEGMENTATION_FASTSEG.out.csf_map

        // ** Freesurfer segmentation ** //
        SEGMENTATION_FREESURFERSEG (
            ch_freesurferseg
                .join(ch_lesions, remainder: true)
                .map{ it[0..2] + [it[3] ?: []] }
        )
        ch_versions = ch_versions.mix(SEGMENTATION_FREESURFERSEG.out.versions.first())

        // ** Setting outputs ** //
        fs_wm_mask = SEGMENTATION_FREESURFERSEG.out.wm_mask
        fs_gm_mask = SEGMENTATION_FREESURFERSEG.out.gm_mask
        fs_csf_mask = SEGMENTATION_FREESURFERSEG.out.csf_mask
        wm_map = Channel.empty()
        gm_map = Channel.empty()
        csf_map = Channel.empty()

    emit:
        wm_mask      = wm_mask                     // channel: [ val(meta), [ wm_mask ] ]
        gm_mask      = gm_mask                     // channel: [ val(meta), [ gm_mask ] ]
        csf_mask     = csf_mask                    // channel: [ val(meta), [ csf_mask ] ]
        wm_map       = wm_map                      // channel: [ val(meta), [ wm_map ] ]
        gm_map       = gm_map                      // channel: [ val(meta), [ gm_map ] ]
        csf_map      = csf_map                     // channel: [ val(meta), [ csf_map ] ]
        fs_wm_mask   = fs_wm_mask                  // channel: [ val(meta), [ wm_mask ] ]
        fs_gm_mask   = fs_gm_mask                  // channel: [ val(meta), [ gm_mask ] ]
        fs_csf_mask  = fs_csf_mask                 // channel: [ val(meta), [ csf_mask ] ]

        versions = ch_versions                     // channel: [ versions.yml ]
}
