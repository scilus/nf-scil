process SEGMENTATION_FASTSURFER {
    tag "$meta.id"
    label 'process_single'

    container "${ 'deepmi/fastsurfer:cpu-v2.2.0' }"

    input:
        tuple val(meta), path(anat), path(fs_license)

    output:
        tuple val(meta), path("${prefix}/")    , emit: fastsurferdirectory
        path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        def prefix = task.ext.prefix ?: "${meta.id}"
        def acq3T = task.ext.acq3T ? "--3T" : ""
        def FASTSURFER_HOME="/fastsurfer"
    """
    $FASTSURFER_HOME/run_fastsurfer.sh --fs_license $fs_license \
                                        --t1 ${anat} \
                                        --sd "." \
                                        --sid ${prefix} \
                                        --seg_only --py python3 \
                                        --allow_root \
                                        ${acq3T}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastsurfer: \$($FASTSURFER_HOME/run_fastsurfer.sh --version)
    END_VERSIONS
    """

    stub:
        def prefix = task.ext.prefix ?: "${meta.id}"

    """
    $FASTSURFER_HOME/run_fastsurfer.sh --version

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastersurfer: 2.2.0+9f37d02
    END_VERSIONS
    """
}
