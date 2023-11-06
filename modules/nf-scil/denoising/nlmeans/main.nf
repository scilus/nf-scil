
process DENOISING_NLMEANS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.5.0.sif':
        'scilus/scilus:1.5.0' }"

    input:
    tuple val(meta), path(image), path(mask)

    output:
    tuple val(meta), path("*_denoised.nii.gz"), emit: image
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = []
    if (mask) args += ["--mask $mask"]

    """
    scil_run_nlmeans.py $image ${prefix}_denoised.nii.gz 1 ${args.join(" ")}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(scil_get_version.py 2>&1)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    scil_run_nlmeans.py -h

    touch ${prefix}_denoised.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(scil_get_version.py 2>&1)
    END_VERSIONS
    """
}
