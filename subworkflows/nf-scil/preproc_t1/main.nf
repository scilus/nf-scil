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

        // ** N4 correction ** //
        ch_N4 = DENOISING_NLMEANS.out.image.map{[it[0], it[1],[],[]]}
        PREPROC_N4 ( ch_N4 )
        ch_versions = ch_versions.mix(PREPROC_N4.out.versions.first())

        // ** Resampling ** //
        ch_resampling = PREPROC_N4.out.image.map{[it[0], it[1],[]]}
        IMAGE_RESAMPLE ( ch_resampling )
        ch_versions = ch_versions.mix(IMAGE_RESAMPLE.out.versions.first())

        // ** Brain extraction ** //
        ch_betcop = IMAGE_RESAMPLE.out.image.join(ch_template).join(ch_probability_map)
        BETCROP_ANTSBET ( ch_betcop )
        ch_versions = ch_versions.mix(BETCROP_ANTSBET.out.versions.first())

        // ** crop ** //
        ch_crop = BETCROP_ANTSBET.out.t1.map{[it[0], it[1],[]]}
        BETCROP_CROPVOLUME ( ch_crop )
        ch_versions = ch_versions.mix(BETCROP_CROPVOLUME.out.versions.first())

    emit:
        image    = BETCROP_CROPVOLUME.out.image // channel: [ val(meta), [ image ] ]
        versions = ch_versions                  // channel: [ versions.yml ]
}

