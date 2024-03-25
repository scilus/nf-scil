// ** Importing modules from nf-scil ** //
include { DENOISING_NLMEANS } from '../../../modules/nf-scil/denoising/nlmeans/main'
include { PREPROC_N4 } from '../../../modules/nf-scil/preproc/n4/main'
include { IMAGE_RESAMPLE } from '../../../modules/nf-scil/image/resample/main'
include { BETCROP_ANTSBET } from '../../../modules/nf-scil/betcrop/antsbet/main'
include { BETCROP_CROPVOLUME } from '../../../modules/nf-scil/betcrop/cropvolume/main'

workflow PREPROC_T1 {

    take:
        ch_image           // channel: [ val(meta), [ image ] ]
        ch_template        // channel: [ val(meta), [ template ] ]
        ch_probability_map // channel: [ val(meta), [ probability_map ] ]

    main:

        ch_versions = Channel.empty()

        // ** Denoising ** //
        DENOISING_NLMEANS ( ch_image )
        ch_versions = ch_versions.mix(DENOISING_NLMEANS.out.versions.first())
/*
waiting for n4 modifications
        // ** N4 correction ** //
        PREPROC_N4 ( DENOISING_NLMEANS.out.image )
        ch_versions = ch_versions.mix(PREPROC_N4.out.versions.first())
*/
        // ** Resampling ** //
        IMAGE_RESAMPLE ( DENOISING_NLMEANS.out.image )
        ch_versions = ch_versions.mix(IMAGE_RESAMPLE.out.versions.first())

        // ** Brain extraction ** //
        BETCROP_ANTSBET ( IMAGE_RESAMPLE.out.image, ch_template, ch_probability_map )
        ch_versions = ch_versions.mix(BETCROP_ANTSBET.out.versions.first())

        // ** crop ** //
        BETCROP_CROPVOLUME ( BETCROP_ANTSBET.out.t1 )
        ch_versions = ch_versions.mix(BETCROP_CROPVOLUME.out.versions.first())

    emit:
        image    = BETCROP_CROPVOLUME.out.image // channel: [ val(meta), [ image ] ]
        versions = ch_versions                  // channel: [ versions.yml ]
}

