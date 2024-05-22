process BUNDLE_STATS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.0.2.sif':
        'scilus/scilus:2.0.2' }"

    input:
    tuple val(meta), path(bundles), path(metrics), path(endpoints_head), path(endpoint_tail), path(voxel_labels_map), path(labels_map), path(distance_map)

    output:
    tuple val(meta), path("*.json"), emit: output
    
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bundle: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bundle: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
