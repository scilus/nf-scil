// ** Importing modules from nf-scil ** //
include { TOPUP } from '../../../modules/nf-scil/preproc/topup/main'
include { EDDY } from '../../../modules/nf-scil/preproc/eddy/main'

workflow TOPUP_EDDY {

    // **
    // **
    // **

    take:
        ch_image // channel: [ val(meta), [ dwi, bval, bvec, b0, rev_dwi, rev_bval, rev_bvec, rev_b0 ] ]
        config_topup // channel: [ config_topup ]

    main:

        ch_versions = Channel.empty()

        if ( config_topup and ( ch_image.rev_dwi or ch_image.rev_b0 ))
        {
            TOPUP ( ch_image, config_topup )
            ch_versions = ch_versions.mix(TOPUP.out.versions.first())
            EDDY ( [ch_image.dwi, ch_image.bval, ch_image.bvec, ch_image.b0, ch_image.rev_dwi, ch_image.rev_bval, ch_image.rev_bvec, ch_image.rev_b0, TOPUP.out.topup_corrected_b0s, TOPUP.out.topup_fieldcoef, TOPUP.out.topup_movpart] )
        }
        else
        {
            EDDY ( ch_image )
        }

        ch_versions = ch_versions.mix(EDDY.out.versions.first())

    emit:
        dwi      = EDDY.out.dwi_corrected       // channel: [ val(meta), [ dwi_corrected ] ]
        bval     = EDDY.out.bval_corrected      // channel: [ val(meta), [ bval_corrected ] ]
        bvec     = EDDY.out.bvec_corrected      // channel: [ val(meta), [ bvec_corrected ] ]
        b0_mask  = EDDY.out.b0_mask             // channel: [ val(meta), [ b0_mask ] ]
        versions = ch_versions                  // channel: [ versions.yml ]
}
