// PREPROCESSING
include { ANATOMICAL_SEGMENTATION                                  } from '../anatomical_segmentation/main'
include { PREPROC_DWI                                              } from '../preproc_dwi/main'
include { PREPROC_T1                                               } from '../preproc_t1/main'
include { REGISTRATION as T1_REGISTRATION                          } from '../registration/main'
include { RECONST_DTIMETRICS as REGISTRATION_FA                    } from '../../../modules/nf-scil/reconst/dtimetrics/main'
include { REGISTRATION_ANTSAPPLYTRANSFORMS as TRANSFORM_WMPARC     } from '../../../modules/nf-scil/registration/antsapplytransforms/main'
include { REGISTRATION_ANTSAPPLYTRANSFORMS as TRANSFORM_APARC_ASEG } from '../../../modules/nf-scil/registration/antsapplytransforms/main'

// RECONSTRUCTION
include { RECONST_FRF        } from '../../../modules/nf-scil/reconst/frf/main'
include { RECONST_MEANFRF    } from '../../../modules/nf-scil/reconst/meanfrf/main'
include { RECONST_DTIMETRICS } from '../../../modules/nf-scil/reconst/dtimetrics/main'
include { RECONST_FODF       } from '../../../modules/nf-scil/reconst/fodf/main'

// TRACKING
include { TRACKING_PFTTRACKING   } from '../../../modules/nf-scil/tracking/pfttracking/main'
include { TRACKING_LOCALTRACKING } from '../../../modules/nf-scil/tracking/localtracking/main'

params.dwi_fodf_fit_use_average_frf = false

workflow TRACTOFLOW {

    take:
        ch_dwi // channel: [ val(meta), dwi_nifti, bval_file, bvec_file ]
        ch_sbref // channel: [ val(meta), sbref_nifti ], optional
        ch_rev_dwi // channel: [ val(meta), rev_dwi_nifti, bval_file, bvec_file ], optional
        ch_rev_sbref // channel: [ val(meta), rev_sbref_nifti ], optional
        ch_t1 // channel: [ val(meta), t1_nifti ]
        ch_wmparc // channel: [ val(meta), wmparc_nifti ], optional
        ch_aparc_aseg // channel: [ val(meta), aparc+aseg_nifti ], optional
        ch_topup_config // channel: [ topup_config_file ], optional
        ch_bet_template // channel: [ bet_template_nifti ]
        ch_bet_probability // channel: [ bet_template_nifti ]

    main:

    ch_versions = Channel.empty()

    /* Unpack inputs */
    ch_inputs = ch_dwi
        .join(ch_sbref, remainder: true)
        .join(ch_rev_dwi, remainder: true)
        .map{ it[5] ? it : it[0..4] + [null, null, null] }
        .join(ch_rev_sbref, remainder: true)
        .join(ch_t1, remainder: true)
        .join(ch_wmparc, remainder: true)
        .join(ch_aparc_aseg, remainder: true)
        .view()
        .multiMap{meta, dwi, bval, bvec, sbref, rev_dwi, rev_bval, rev_bvec, rev_sbref, t1, wmparc, aparc_aseg ->
            dwi: [meta, dwi, bval, bvec]
            sbref: sbref ? [meta, sbref] : []
            rev_dwi: rev_dwi ? [meta, rev_dwi, rev_bval, rev_bvec] : []
            rev_sbref: rev_sbref ? [meta, rev_sbref] : []
            t1: [meta, t1]
            wmparc: wmparc ? [meta, wmparc] : []
            aparc_aseg: aparc_aseg ? [meta, aparc_aseg] : []
        }

    /* PREPROCESSING */

    //
    // SUBWORKFLOW: Run PREPROC_DWI
    //
    PREPROC_DWI(
        ch_inputs.dwi, ch_inputs.rev_dwi.filter{ it },
        ch_inputs.sbref.filter{ it }, ch_inputs.rev_sbref.filter{ it },
        ch_topup_config.ifEmpty( "b02b0.cnf" )
    )
    ch_versions = ch_versions.mix(PREPROC_DWI.out.versions.first())

    //
    // SUBWORKFLOW: Run PREPROC_T1
    //
    ch_t1_meta = ch_inputs.t1.map{ it[0] }
    PREPROC_T1(
        ch_inputs.t1,
        ch_t1_meta.combine(ch_bet_template),
        ch_t1_meta.combine(ch_bet_probability),
        Channel.empty(),
        Channel.empty(),
        Channel.empty()
    )
    ch_versions = ch_versions.mix(PREPROC_T1.out.versions.first())

    //
    // MODULE: Run RECONST/DTIMETRICS (REGISTRATION_FA)
    //
    ch_registration_fa = PREPROC_DWI.out.dwi_resample
        .join(PREPROC_DWI.out.bval)
        .join(PREPROC_DWI.out.bvec)
        .join(PREPROC_DWI.out.b0_mask)
    REGISTRATION_FA( ch_registration_fa )
    ch_versions = ch_versions.mix(REGISTRATION_FA.out.versions.first())

    //
    // SUBWORKFLOW: Run REGISTRATION
    //
    T1_REGISTRATION(
        PREPROC_T1.out.t1_final,
        PREPROC_DWI.out.b0,
        REGISTRATION_FA.out.fa,
        []
    )
    ch_versions = ch_versions.mix(T1_REGISTRATION.out.versions.first())

    /* SEGMENTATION */

    //
    // MODULE: Run REGISTRATION_ANTSAPPLYTRANSFORMS (TRANSFORM_WMPARC)
    //
    TRANSFORM_WMPARC(
        ch_inputs.wmparc
            .filter{ it[1] }
            .join(PREPROC_DWI.out.b0)
            .join(T1_REGISTRATION.out.transfo_image)
            .map{ it[0..2] + [it[3..-1]] }
    )
    ch_versions = ch_versions.mix(TRANSFORM_WMPARC.out.versions.first())

    //
    // MODULE: Run REGISTRATION_ANTSAPPLYTRANSFORMS (TRANSFORM_APARC_ASEG)
    //
    TRANSFORM_APARC_ASEG(
        ch_inputs.aparc_aseg
            .filter{ it[1] }
            .join(PREPROC_DWI.out.b0)
            .join(T1_REGISTRATION.out.transfo_image)
            .map{ it[0..2] + [it[3..-1]] }
    )
    ch_versions = ch_versions.mix(TRANSFORM_APARC_ASEG.out.versions.first())

    //
    // SUBWORKFLOW: Run ANATOMICAL_SEGMENTATION
    //
    ANATOMICAL_SEGMENTATION(
        T1_REGISTRATION.out.image_warped,
        TRANSFORM_WMPARC.out.warped_image
            .join(TRANSFORM_APARC_ASEG.out.warped_image),
        Channel.empty()
    )
    ch_versions = ch_versions.mix(ANATOMICAL_SEGMENTATION.out.versions.first())

    /* RECONSTRUCTION */

    //
    // MODULE: Run RECONST/DTIMETRICS
    //
    ch_dti_metrics = PREPROC_DWI.out.dwi_resample
        .join(PREPROC_DWI.out.bval)
        .join(PREPROC_DWI.out.bvec)
        .join(PREPROC_DWI.out.b0_mask)
    RECONST_DTIMETRICS( ch_dti_metrics )
    ch_versions = ch_versions.mix(RECONST_DTIMETRICS.out.versions.first())

    //
    // MODULE: Run RECONST/FRF
    //
    ch_reconst_frf = PREPROC_DWI.out.dwi_resample
        .join(PREPROC_DWI.out.bval)
        .join(PREPROC_DWI.out.bvec)
        .join(PREPROC_DWI.out.b0_mask)
        .join(ANATOMICAL_SEGMENTATION.out.wm_mask)
        .join(ANATOMICAL_SEGMENTATION.out.gm_mask)
        .join(ANATOMICAL_SEGMENTATION.out.csf_mask)
    RECONST_FRF( ch_reconst_frf )
    ch_versions = ch_versions.mix(RECONST_FRF.out.versions.first())

    /* Run fiber response aeraging over subjects */
    ch_fiber_response = RECONST_FRF.out.frf.map{ it.flatten() }
    if ( params.dwi_fodf_fit_use_average_frf ) {
        RECONST_MEANFRF( RECONST_FRF.out.frf.map{ it[1] }.flatten() )
        ch_versions = ch_versions.mix(RECONST_MEANFRF.out.versions.first())
        ch_fiber_response = RECONST_FRF.out.map{ it[0] }
            .combine( RECONST_MEANFRF.out.meanfrf )
    }

    ch_fiber_response = ch_fiber_response
        .map{ it.size() > 2 ? it : it + [[], []] }

    //
    // MODULE: Run RECONST/FODF
    //
    ch_reconst_fodf = PREPROC_DWI.out.dwi_resample
        .join(PREPROC_DWI.out.bval)
        .join(PREPROC_DWI.out.bvec)
        .join(PREPROC_DWI.out.b0_mask)
        .join(RECONST_DTIMETRICS.out.fa)
        .join(RECONST_DTIMETRICS.out.md)
        .join(ch_fiber_response)
    RECONST_FODF( ch_reconst_fodf )
    ch_versions = ch_versions.mix(RECONST_FODF.out.versions.first())

    //
    // MODULE: Run TRACKING/PFTTRACKING
    //
    ch_pft_tracking = ANATOMICAL_SEGMENTATION.out.wm_mask
        .join(ANATOMICAL_SEGMENTATION.out.gm_mask)
        .join(ANATOMICAL_SEGMENTATION.out.csf_mask)
        .join(RECONST_FODF.out.fodf)
        .join(RECONST_DTIMETRICS.out.fa)
    TRACKING_PFTTRACKING( ch_pft_tracking )
    ch_versions = ch_versions.mix(TRACKING_PFTTRACKING.out.versions.first())

    //
    // MODULE: Run TRACKING/LOCALTRACKING
    //
    ch_local_tracking = ANATOMICAL_SEGMENTATION.out.wm_mask
        .join(RECONST_FODF.out.fodf)
        .join(RECONST_DTIMETRICS.out.fa)
    TRACKING_LOCALTRACKING( ch_local_tracking )
    ch_versions = ch_versions.mix(TRACKING_LOCALTRACKING.out.versions.first())

    // define output channels
    ch_dwi_preprocessed = PREPROC_DWI.out.dwi_resample
        .join(PREPROC_DWI.out.bval)
        .join(PREPROC_DWI.out.bvec)
    ch_brain_mask = PREPROC_DWI.out.b0_mask
    ch_t1_registered = T1_REGISTRATION.out.image_warped
    ch_t1_to_b0_transform = T1_REGISTRATION.out.transfo_image
        .join(T1_REGISTRATION.out.transfo_trk)
    ch_tissues_masks = ANATOMICAL_SEGMENTATION.out.wm_mask
        .join(ANATOMICAL_SEGMENTATION.out.gm_mask)
        .join(ANATOMICAL_SEGMENTATION.out.csf_mask)
    ch_tissues_maps = ANATOMICAL_SEGMENTATION.out.wm_map
        .join(ANATOMICAL_SEGMENTATION.out.gm_map)
        .join(ANATOMICAL_SEGMENTATION.out.csf_map)
    ch_dti_tensor = RECONST_DTIMETRICS.out.tensor
    ch_dti_metrics = RECONST_DTIMETRICS.out.ad
        .join(RECONST_DTIMETRICS.out.rd)
        .join(RECONST_DTIMETRICS.out.md)
        .join(RECONST_DTIMETRICS.out.fa)
        .join(RECONST_DTIMETRICS.out.ga)
        .join(RECONST_DTIMETRICS.out.rgb)
        .join(RECONST_DTIMETRICS.out.evecs_v1)
        .join(RECONST_DTIMETRICS.out.evecs_v2)
        .join(RECONST_DTIMETRICS.out.evecs_v3)
        .join(RECONST_DTIMETRICS.out.evals_e1)
        .join(RECONST_DTIMETRICS.out.evals_e2)
        .join(RECONST_DTIMETRICS.out.evals_e3)
        .join(RECONST_DTIMETRICS.out.residual)
        .join(RECONST_DTIMETRICS.out.nonphysical)
        .join(RECONST_DTIMETRICS.out.mode)
        .join(RECONST_DTIMETRICS.out.norm)
    ch_local_tractogram = TRACKING_LOCALTRACKING.out.trk
        .join(TRACKING_LOCALTRACKING.out.config)
    ch_pft_tractogram = TRACKING_PFTTRACKING.out.trk
        .join(TRACKING_PFTTRACKING.out.config)

    emit:
        dwi = ch_dwi_preprocessed
            // channel: [ val(meta), path(*.nii.gz), path(*.bval), path(*.bvec) ]
        brain_mask = ch_brain_mask
            // channel: [ val(meta), path(*.nii.gz) ]
        t1 = ch_t1_registered
            // channel: [ val(meta), path(*.nii.gz) ]
        t1_to_b0_transformations = ch_t1_to_b0_transform
            // channel: [ val(meta), [path(*.nii.gz | *.txt), ...], [path(*.nii.gz | *.txt), ...] ]
        tissues_masks = ch_tissues_masks
            // channel: [ val(meta), path(*.nii.gz), path(*.nii.gz), path(*.nii.gz) ]
        tissues_maps = ch_tissues_maps
            // channel: [ val(meta), path(*.nii.gz), path(*.nii.gz), path(*.nii.gz) ]
        dti_tensor = ch_dti_tensor
            // channel: [ val(meta), path(*.nii.gz) ]
        dti_metrics = ch_dti_metrics
            // channel: [ val(meta), path(*.nii.gz), path(*.nii.gz), ... ]
        frf = ch_fiber_response
            // channel: [ val(meta), path(*.txt) ]
        fodf = RECONST_FODF.out.fodf
            // channel: [ val(meta), path(*.nii.gz) ]
        local_tractogram = ch_local_tractogram
            // channel: [ val(meta), path(*.trk), path(*.json) ]
        pft_tractogram = ch_pft_tractogram
            // channel: [ val(meta), path(*.trk), path(*.json) ]
        versions       = ch_versions
            // channel: [ path(versions.yml) ]
}

