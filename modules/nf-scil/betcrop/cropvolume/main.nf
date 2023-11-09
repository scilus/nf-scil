
process BETCROP_CROPVOLUME {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.5.0.sif':
        'scilus/scilus:1.5.0' }"

    input:
    tuple val(meta), path(image), path(mask)

    output:
    tuple val(meta), path("*_cropped.nii.gz"), emit: image
    tuple val(meta), path("*.pkl")           , emit: crop_box, optional: true
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    if ( task.ext.output_bbox ) args = "$args --output_bbox ${prefix}_bbox.pkl"

    """
    scil_crop_volume.py $image ${prefix}_cropped.nii.gz $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(scil_get_version.py 2>&1)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    scil_crop_volume.py -h

    touch ${prefix}_cropped.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(scil_get_version.py 2>&1)
    END_VERSIONS
    """
}
