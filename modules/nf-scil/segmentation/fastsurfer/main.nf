process SEGMENTATION_FASTSURFER {
    tag "$meta.id"
    label 'process_single'

    container "${ 'deepmi/fastsurfer:cpu-v2.2.0' }"

    containerOptions '--entrypoint ""'

    input:
        tuple val(meta), path(anat), path(fs_license)

    output:
        tuple val(meta), path("${prefix}_fastsurfer/")    , emit: fastsurferdirectory
        path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        def prefix = task.ext.prefix ?: "${meta.id}"
        def acq3T = task.ext.acq3T ? "--3T" : ""
        def FASTSURFER_HOME = "/fastsurfer"
        def SUBJECTS_DIR = "${prefix}_fastsurfer"
    """
    mkdir ${prefix}_fastsurfer/
    $FASTSURFER_HOME/run_fastsurfer.sh  --allow_root \
                                        --fs_license $fs_license \
                                        --t1 \$(realpath ${anat}) \
                                        --sd ${SUBJECTS_DIR}/ \
                                        --sid ${prefix} \
                                        --seg_only --py python3 \
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
