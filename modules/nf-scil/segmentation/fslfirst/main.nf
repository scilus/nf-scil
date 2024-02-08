
process SEGMENTATION_FSLFIRST {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'scilus/scilus:1.2.0':
        'scilus/scilus:1.2.0' }"

    input:
    tuple val(meta), path(image)

    output:
    tuple val(meta), path("*_all_fast_firstseg.nii.gz"), emit: subcortex_segmentation
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    run_first_all -i ${image} -o ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.2.0
        fsl: \$(run_first_all -version 2>&1 | sed -n 's/FIRST version \\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    run_first_all -h

    touch ${prefix}_all_fast_firstseg.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.2.0
        fsl: \$(run_first_all -version 2>&1 | sed -n 's/FIRST version \\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """
}