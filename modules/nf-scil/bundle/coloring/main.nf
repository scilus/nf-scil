
process BUNDLE_COLORING {
    tag "$meta.id"
    label 'process_single'


    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'bscilus/scilus:1.6.0' }"

    input:

    tuple val(meta), path(bundles)

    output:

    tuple val(meta), path("*_colored.trk"), emit: bundles

    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def json_str = JsonOutput.toJson(params.colors)
    String bundles_list = bundles.join(", ").replace(',', '')

    """
    echo '$json_str' >> colors.json
    scil_assign_uniform_color_to_tractograms.py $bundles_list --dict_colors colors.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    #L38-L54

    """
    touch ${prefix}._colored.trk

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
