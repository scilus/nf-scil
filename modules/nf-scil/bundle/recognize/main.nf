process BUNDLE_RECOGNIZE {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(tractograms), path(transform), path(config), path(directory)

    output:
    tuple val(meta), path("${sid}__*_cleaned.trk")     , emit: bundles
    path "versions.yml"                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    // additional script arguments
    def minimal_vote_ratio = task.ext.minimal_vote_ratio ? "--minimal_vote_ratio " + task.ext.minimal_vote_ratio : ""
    def seed = task.ext.seed ? "--seed " + task.ext.seed : ""
    def rbx_processes = task.ext.rbx_processes ? "--rbx_processes " + task.ext.rbx_processes : ""
    def outlier_atlas = task.ext.outlier_alpha ? "--alpha " + task.ext.outlier_alpha : ""
    """
    mkdir recobundles/
    scil_recognize_multi_bundles.py ${tractograms} ${config} ${directory}/ ${transform} --inverse --out_dir recobundles/ \
        --log_level DEBUG $minimal_vote_ratio $seed $rbx_processes

    for bundle_file in recobundles/*; do
        bname=\$(basename \${bundle_file} .trk)
        out_cleaned=${prefix}__\${bname}_cleaned.trk
        scil_outlier_rejection.py \${bundle_file} "\${out_cleaned}" ${outlier_alpha}
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    scil_recognize_multi_bundles.py -h
    scil_outlier_rejection.py -h

    # dummy output for single bundle
    touch ${prefix}__AF_L_cleaned.trk

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
