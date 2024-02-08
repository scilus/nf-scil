process SEGMENTATION_FSRECONALL {
    tag "$meta.id"
    label 'process_single'

    # TODO Voir comment ajouter FreeSurfer!
    # Note. Freesurfer is already on Docker. See documentation on
    # https://hub.docker.com/r/freesurfer/freesurfer
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        freesurfer/freesurfer:7.1.1}"

    input:
        tuple val(meta), path(anat)

    output:
        path("*__recon_all")                    , emit: recon_all_out_folder
        path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    export SUBJECTS_DIR=.
    recon-all -i $anat -s ${prefix}__recon_all -all -parallel -openmp $params.nb_threads

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
