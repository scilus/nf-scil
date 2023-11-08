process PREPROC_N4 {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
    tuple val(meta), path(dwi), path(b0), path(b0_mask)

    output:
    tuple val(meta), path("*dwi_n4.nii.gz")     , emit: dwi
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    export ANTS_RANDOM_SEED=1234

    N4BiasFieldCorrection -i $b0\
        -o [${prefix}__b0_n4.nii.gz, bias_field_b0.nii.gz]\
        -c [300x150x75x50, 1e-6] -v 1

    scil_apply_bias_field_on_dwi.py $dwi bias_field_b0.nii.gz\
        ${prefix}__dwi_n4.nii.gz --mask $b0_mask -f

    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            scilpy: 1.6.0
            N4BiasFieldCorrection: \$(N4BiasFieldCorrection --version 2>&1 | sed -n 's/ANTs Version: v\\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    N4BiasFieldCorrection.py -h
    scil_apply_bias_field_on_dwi -h

    touch ${prefix}_dwi_n4.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
            N4BiasFieldCorrection: \$(N4BiasFieldCorrection --version 2>&1 | sed -n 's/ANTs Version: v\\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """
}
