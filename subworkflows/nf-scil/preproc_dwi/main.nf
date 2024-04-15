include { BETCROP_FSLBETCROP as BET_PRELIM } from '../../../modules/nf-scil/betcrop/fslbetcrop/main'
include { DENOISING_MPPCA as DENOISE_DWI } from '../../../modules/nf-scil/denoising/mppca/main'
include { UTILS_EXTRACTB0 } from '../../../modules/nf-scil/utils/extractb0/main'
include { TOPUP_EDDY } from '../../../subworflows/nf-scil/topup_eddy/main'
include { BETCROP_FSLBETCROP } from '../../../modules/nf-scil/betcrop/fslbetcrop/main'
include { PREPROC_N4 as N4_DWI } from '../../../modules/nf-scil/preproc/n4/main'
include { PREPROC_NORMALIZE as NORMALIZE_DWI } from '../../../modules/nf-scil/preproc/normalize/main'
include { IMAGE_RESAMPLE as RESAMPLE_DWI } from '../../../modules/nf-scil/image/resample/main'


workflow PREPROC_DWI {

    take:
       ch_dwi     // channel: [ val(meta), [ dwi ] ]
       ch_bval_bvec // channel: [ val(meta), [ bval, bvec] ]
       ch_rev_b0    // channel: [ val(meta), [ reverse b0 ] ]

    main:

        ch_versions = Channel.empty()

        // ** Preliminary BET DWI ** : dwi//
        BET_PRELIM ( ch_dwi )
        ch_versions = ch_versions.mix(BET_PRELIM.out.versions.first())

        // ** Denoised DWI : dwi ** //
        DENOISE_DWI ( BET_PRELIM.out.image )
        ch_versions = ch_versions.mix(DENOISE_DWI.out.versions.first())

        // ** Eddy Topup DWI ** : dwi, bval, bvec, b0 (opt), rev_dwi, rev_bval, rev_bvec, rev_b0 (opt)//
        // Need to see with Arnaud for the other inputs //
        if ( ch_rev_b0 ) {
            // ** Set up input channel with reverse b0 ** //
            ch_topup_eddy = DENOISING_MPPCA.out.image.join(ch_bval_bvec).join(ch_rev_b0)
            TOPUP_EDDY ( ch_topup_eddy )
            ch_versions = ch_versions.mix(TOPUP_EDDY.out.versions.first())
        }
        else {
            // ** Set up input channel without reverse b0 ** //
            ch_eddy = DENOISING_MPPCA.out.image.join(ch_bval_bvec)
            TOPUP_EDDY ( ch_eddy )
            ch_versions = ch_versions.mix(TOPUP_EDDY.out.versions.first())
        }

        // ** Extract b0 : dwi, bval, bvec ** //
        ch_extract_b0 = TOPUP_EDDY.out.dwi_corrected.join(
                            TOPUP_EDDY.out.bval,
                            TOPUP_EDDY.out.bvec)
        UTILS_EXTRACTB0 ( ch_extract_b0 )
        ch_versions = ch_versions.mix(UTILS_EXTRACTB0.out.versions.first())

        // ** Bet-crop DWI **: dwi, bval, bvec //
        ch_betcop = TOPUP_EDDY.out.dwi_corrected.join(
                            TOPUP_EDDY.out.bval,
                            TOPUP_EDDY.out.bvec)
        BETCROP_FSLBETCROP ( ch_betcop )
        ch_versions = ch_versions.mix(BETCROP_FSLBETCROP.out.versions.first())

        // ** N4 DWI ** : dwi, b0, b0mask //
        ch_N4 = BETCROP_FSLBETCROP.out.image.join(
                            UTILS_EXTRACTB0.out.b0,
                            BETCROP_FSLBETCROP.out.mask)
        N4_DWI ( ch_N4 )
        ch_versions = ch_versions.mix(N4_DWI.out.versions.first())

        // ** Normalize DWI ** : dwi, mask, bval, bvec//
        ch_normalize = N4_DWI.out.image.join(
                            TOPUP_EDDY.out.b0_mask,
                            TOPUP_EDDY.out.bval,
                            TOPUP_EDDY.out.bvec)
        NORMALIZE_DWI ( ch_normalize )
        ch_versions = ch_versions.mix(NORMALIZE_DWI.out.versions.first())

        // ** Resampling DWI ** :  dwi, []//
        ch_resampling = NORMALIZE_DWI.out.dwi.map{[it[0], it[1],[]]}
        RESAMPLE_DWI ( ch_resampling )
        ch_versions = ch_versions.mix(RESAMPLE_DWI.out.versions.first()))

    emit:
        dwi_resample    = RESAMPLE_DWI.out.image        // channel: [ val(meta), [ dwi_resample ] ]
        bval            = TOPUP_EDDY.out.bval_corrected // channel: [ val(meta), [ bval_corrected ] ]
        bvec            = TOPUP_EDDY.out.bvec_corrected // channel: [ val(meta), [ bvec_corrected ] ]
        b0              = UTILS_EXTRACTB0.out.b0        // channel: [ val(meta), [ b0 ] ]
        b0_mask         = TOPUP_EDDY.out.out.b0_mask    // channel: [ val(meta), [ b0_mask ] ]
        versions        = ch_versions                   // channel: [ versions.yml ]
}
