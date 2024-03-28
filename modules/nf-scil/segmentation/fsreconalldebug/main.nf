process SEGMENTATION_FSRECONALLDEBUG {
    tag "$meta.id"
    label 'process_single'

    // Note. Freesurfer is already on Docker. See documentation on
    // https://hub.docker.com/r/freesurfer/freesurfer
    container "freesurfer/freesurfer:7.1.1"

    input:
        tuple val(meta), path(anat), path(fs_license) /* optional, value = [] */

    output:
        path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    /*
    Can't simply call the help :(. Badly programmed: Returns with exit status (1) = bug!
    recon-all -help
    We will at least verify that it is found.
    Tried to do : which recon-all, but error: which: command not found.
    */
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo \$FREESURFER_HOME
    ls \$FREESURFER_HOME/bin/r*
    if [ ! -f "\$FREESURFER_HOME/bin/recon-all" ]; then
        echo "COMMAND NOT FOUND"
        recon-all -help  # Voluntary error.
    fi

    # Finish
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freesurfer: 7.1.1
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    recon-all -help

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freesurfer: 7.1.1
    END_VERSIONS
    """
}
