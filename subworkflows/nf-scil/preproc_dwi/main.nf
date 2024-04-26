include { DENOISING_MPPCA as DENOISE_DWI } from '../../../modules/nf-scil/denoising/mppca/main'
include { DENOISING_MPPCA as DENOISE_REVDWI } from '../../../modules/nf-scil/denoising/mppca/main'
include { BETCROP_FSLBETCROP } from '../../../modules/nf-scil/betcrop/fslbetcrop/main'
include { PREPROC_N4 as N4_DWI } from '../../../modules/nf-scil/preproc/n4/main'
include { PREPROC_NORMALIZE as NORMALIZE_DWI } from '../../../modules/nf-scil/preproc/normalize/main'
include { IMAGE_RESAMPLE as RESAMPLE_DWI } from '../../../modules/nf-scil/image/resample/main'
include { TOPUP_EDDY } from '../../subworkflows/nf-scil/topup_eddy/main'


workflow PREPROC_DWI {

    take:
       ch_dwi           // channel: [ val(meta), [ dwi, bval, bvec ] ]
       ch_rev_dwi       // channel: [ val(meta), [ rev_dwi, bval, bvec ] ], optional
       ch_b0            // Channel: [ val(meta), [ b0 ] ], optional
       ch_rev_b0        // channel: [ val(meta), [ reverse b0 ] ], optional
       ch_config_topup  // channel: [ 'config_topup' ], optional

    main:

        ch_versions = Channel.empty()

        // ** Denoised DWI ** //
        DENOISE_DWI ( ch_dwi.dwi )
        ch_versions = ch_versions.mix(DENOISE_DWI.out.versions.first())

        if ( ch_rev_dwi )
        {
            // ** Denoised reverse DWI ** //
            DENOISE_REVDWI ( ch_rev_dwi.dwi )
        }

        // ** Eddy Topup ** //
        ch_topup_eddy_dwi = DENOISE_DWI.out.image.join(ch_dwi.bval, ch_dwi.bvec)
        ch_topup_eddy_rev_dwi = DENOISE_REVDWI.out.image.join(ch_rev_dwi.bval, ch_rev_dwi.bvec)
        TOPUP_EDDY ( ch_topup_eddy_dwi, ch_b0, ch_topup_eddy_rev_dwi, ch_rev_b0, ch_config_topup )
        ch_versions = ch_versions.mix(TOPUP_EDDY.out.versions.first())

        // ** Bet-crop DWI ** //
        ch_betcop = TOPUP_EDDY.out.dwi_corrected.join(
                            TOPUP_EDDY.out.bval_corrected,
                            TOPUP_EDDY.out.bvec_corrected)
        BETCROP_FSLBETCROP ( ch_betcop )
        ch_versions = ch_versions.mix(BETCROP_FSLBETCROP.out.versions.first())

        // ** N4 DWI ** //
        ch_N4 = BETCROP_FSLBETCROP.out.image.join(
            TOPUP_EDDY.out.b0,
            BETCROP_FSLBETCROP.out.mask)
        N4_DWI ( ch_N4 )
        ch_versions = ch_versions.mix(N4_DWI.out.versions.first())

        // ** Normalize DWI ** //
        ch_normalize = N4_DWI.out.image.join(
            TOPUP_EDDY.out.b0_mask,
            TOPUP_EDDY.out.bval_corrected,
            TOPUP_EDDY.out.bvec_corrected)
        NORMALIZE_DWI ( ch_normalize )
        ch_versions = ch_versions.mix(NORMALIZE_DWI.out.versions.first())

        // ** Resampling DWI ** //
        ch_resampling = NORMALIZE_DWI.out.dwi.map{ it + [[]] }
        RESAMPLE_DWI ( ch_resampling )
        ch_versions = ch_versions.mix(RESAMPLE_DWI.out.versions.first())

    emit:
        dwi_resample        = RESAMPLE_DWI.out.image            // channel: [ val(meta), [ dwi_resample ] ]
        bval                = TOPUP_EDDY.out.bval_corrected     // channel: [ val(meta), [ bval_corrected ] ]
        bvec                = TOPUP_EDDY.out.bvec_corrected     // channel: [ val(meta), [ bvec_corrected ] ]
        b0                  = TOPUP_EDDY.out.b0                 // channel: [ val(meta), [ b0 ] ]
        b0_mask             = TOPUP_EDDY.out.b0_mask            // channel: [ val(meta), [ b0_mask ] ]
        dwi_bounding_box    = BETCROP_FSLBETCROP.out.bbox       // channel: [ val(meta), [ dwi_bounding_box ] ]
        dwi_topup_eddy      = TOPUP_EDDY.out.dwi_corrected      // channel: [ val(meta), [ dwi_topup_eddy ] ]
        dwi_n4              = N4_DWI.out.image                  // channel: [ val(meta), [ dwi_n4 ] ]
        versions            = ch_versions                       // channel: [ versions.yml ]
}
