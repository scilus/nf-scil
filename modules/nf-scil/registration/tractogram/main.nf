process REGISTRATION_TRACTOGRAM {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.0.2.sif':
        'scilus/scilus:2.0.2' }"

    input:
    tuple val(meta), path(anat), path(transfo), path(tractograms_dir, stageAs: 'tractograms/'), path(ref) /* optional, value = [] */, path(deformation) /* optional, value = [] */

    output:
    tuple val(meta), path("*__*.{trk,tck}"), emit: warped_tractogram
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def reference = "$ref" ? "--reference $ref" : ""
    def in_deformation = "$deformation" ? "--in_deformation $deformation" : ""

    def inverse = task.ext.inverse ? "--inverse" : ""
    def reverse_operation = task.ext.reverse_operation ? "--reverse_operation" : ""
    def force = task.ext.force ? "-f" : ""

    def cut_invalid = task.ext.cut_invalid ? "--cut_invalid" : ""
    def remove_single_point = task.ext.remove_single_point ? "--remove_single_point" : ""
    def remove_overlapping_points = task.ext.remove_overlapping_points ? "--remove_overlapping_points" : ""
    def threshold = task.ext.threshold ? "--threshold " + task.ext.threshold : ""
    def no_empty = task.ext.no_empty ? "--no_empty" : ""

    """
    for tractogram in ${tractograms_dir};
        do \
        bname=\${tractogram/${prefix}_/_}
        ext=\${tractogram#*.}
        bname=\$(basename \${bname} .\${ext})

        scil_tractogram_apply_transform.py \$tractogram $anat $transfo tmp.trk\
                        $in_deformation\
                        $inverse\
                        $reverse_operation\
                        $force\
                        $reference

        scil_tractogram_remove_invalid.py tmp.trk ${prefix}__\${bname}.\${ext}\
                        $cut_invalid\
                        $remove_single_point\
                        $remove_overlapping_points\
                        $threshold\
                        $no_empty\
                        -f
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    for tractogram in ${tractograms_dir};
        do \
        bname=\${tractogram/${prefix}_/_}
        ext=\${tractogram#*.}
        bname=\$(basename \${bname} .\${ext})

        touch ${prefix}__\${bname}.\${ext}
    done

    scil_apply_transform_to_tractogram.py -h
    scil_remove_invalid_streamlines.py -h

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
