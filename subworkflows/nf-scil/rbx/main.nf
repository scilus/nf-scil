import java.util.zip.*
import org.apache.commons.io.FileUtils
import java.nio.file.Files
import java.nio.file.Paths
import java.util.zip.ZipFile

include { REGISTRATION_ANTS                 } from '../../../modules/nf-scil/registration/ants/main'
include { BUNDLE_RECOGNIZE                  } from '../../../modules/nf-scil/bundle/recognize/main'

def fetch_rbx_atlas(atlasUrl, configUrl, dest) {

    def atlas = new File("$dest/atlas.zip").withOutputStream { out ->
        new URL(atlasUrl).withInputStream { from -> out << from; }
    }

    def config = new File("$dest/config.zip").withOutputStream { out ->
        new URL(configUrl).withInputStream { from -> out << from; }
    }
    
    def atlasFile = new ZipFile("$dest/atlas.zip")
    atlasFile.entries().each { it ->
        def path = Paths.get("$dest/atlas/" + it.name)
        if(it.directory){
            Files.createDirectories(path)
        }
        else {
            def parentDir = path.getParent()
            if (!Files.exists(parentDir)) {
                Files.createDirectories(parentDir)
            }
            Files.copy(atlasFile.getInputStream(it), path)
        }
    }

    def configFile = new ZipFile("$dest/config.zip")
    configFile.entries().each { it ->
        def path = Paths.get("$dest/config/" + it.name)
        if(it.directory){
            Files.createDirectories(path)
        }
        else {
            def parentDir = path.getParent()
            if (!Files.exists(parentDir)) {
                Files.createDirectories(parentDir)
            }
            Files.copy(configFile.getInputStream(it), path)
        }
    }
}

workflow RBX {

    take:
        ch_fa               // channel: [ val(meta), [ fa ] ]
        ch_tractogram       // channel: [ val(meta), [ tractogram ] ]
        atlas_directory     // channel: [ directory ], optional: True

    main:

        ch_versions = Channel.empty()

        // ** Setting up Atlas reference channels. ** //
        if ( atlas_directory ) {
            atlas_anat = Channel.fromPath("$atlas_directory/mni_masked.nii.gz")
            atlas_config = Channel.fromPath("$atlas_directory/config_fss_1.json")
            atlas_directory = Channel.fromPath("$atlas_directory/atlas/")
        }
        else {
            fetch_rbx_atlas("https://zenodo.org/records/10103446/files/atlas.zip?download=1",
                            "https://zenodo.org/records/10103446/files/config.zip?download=1",
                            "${workflow.workDir}/")
            atlas_anat = Channel.fromPath("$workflow.workDir/atlas/mni_masked.nii.gz")
            atlas_config = Channel.fromPath("$workflow.workDir/config/config_fss_1.json")
            atlas_directory = Channel.fromPath("$workflow.workDir/atlas/atlas/")
        }

        // ** Register subject's FA map to atlas space. Set up atlas file as moving image ** //
        // ** and subject anat as fixed image.                                            ** //
        ch_register =  ch_fa.combine(atlas_anat)
                            .map{ it + [[]] }

        REGISTRATION_ANTS ( ch_register )
        ch_versions = ch_versions.mix(REGISTRATION_ANTS.out.versions.first())

        // ** Perform bundle recognition and segmentation ** //
        ch_recognize_bundle =  ch_tractogram.combine(REGISTRATION_ANTS.out.transfo_trk.map{ [it[0], it[1]] }, by: 0)
                                            .combine(atlas_config)
                                            .combine(atlas_directory)

        BUNDLE_RECOGNIZE ( ch_recognize_bundle )
        ch_versions = ch_versions.mix(BUNDLE_RECOGNIZE.out.versions.first())


    emit:
        bundles      = BUNDLE_RECOGNIZE.out.bundles         // channel: [ val(meta), [ bundles ] ]

        versions = ch_versions                              // channel: [ versions.yml ]
}
