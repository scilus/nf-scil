

process REGISTER_ANTSAPPLY {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
    tuple val(meta), path(moving), path(reference), path(transfo)

    output:
    tuple val(meta), path("*_warped.nii.gz")             , emit: warped_images
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def interpolation = task.ext.interpolation ? "-n " + task.ext.interpolation : ""
    def data_type = task.ext.data_type ? "-u " + task.ext.data_type : ""
    """
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    export ANTS_RANDOM_SEED=1234

    antsApplyTransforms -d 3 -i $moving -r $reference \
        -o ${moving.getSimpleName()}_warped.nii.gz -t $transfo $interpolation $data_type

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        antsApplyTransforms: \$(antsApplyTransforms --version 2>&1 | sed -n 's/ANTs Version: v\\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    antsApplyTransforms -h

    touch ${prefix}_warped.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        antsApplyTransforms: \$(antsApplyTransforms --version 2>&1 | sed -n 's/ANTs Version: v\\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """
}
