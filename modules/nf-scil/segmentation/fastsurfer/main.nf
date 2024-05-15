process SEGMENTATION_FASTSURFER {
    tag "$meta.id"
    label 'process_single'

    container "${ 'deepmi/fastsurfer:cpu-v2.2.0' }"

    input:
        tuple val(meta), path(anat)

    output:
        tuple val(meta), path("${meta}")    , emit: fastsurferdirectory
        path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def acq3T = task.ext.acq3T : "--3T" : ""

    """
    FASTSURFER_HOME=$FASTSURFER_HOME \
    $FASTSURFER_HOME/run_fastsurfer.sh --t1 ${anat} \
                                       --sd "{SETUP_DIR}fastsurfer_seg" \
                                       --sid ${meta} \
                                       --seg_only --py python3 \
                                       --allow_root \
                                       ${acq3T}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        segmentation: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """

    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    run_fastsurfer.sh -h

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastersurfer: 2.2.0
    END_VERSIONS
}
