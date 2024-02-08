process SEGMENTATION_FSRECONALL {
    tag "$meta.id"
    label 'process_single'

    // Note. Freesurfer is already on Docker. See documentation on
    // https://hub.docker.com/r/freesurfer/freesurfer
    container "freesurfer/freesurfer:7.1.1"

    input:
        tuple val(meta), path(anat)

    output:
        path("*__recon_all")                    , emit: recon_all_out_folder
        path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    // Note. In dsl1, we used an additional option:   -parallel -openmp $params.nb_threads.
    // Removed here.
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    export SUBJECTS_DIR=.

    recon-all -i $anat -s ${prefix}__recon_all -all

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freesurfer: 7.1.1
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    recon-all -help

    mkdir ${prefix}__recon_all

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freesurfer: 7.1.1
    END_VERSIONS
    """
}
