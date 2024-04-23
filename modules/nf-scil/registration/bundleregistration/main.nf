process REGISTRATION_BUNDLEREGISTRATION {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
    tuple val(meta), path(anat), path(transfo), path(centroids_dir, stageAs: 'centroids/'), path(ref) /* optional, value = [] */, path(deformation) /* optional, value = [] */

    output:
    tuple val(meta), path("*__*.trk"), emit: warped_bundle
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def reference = "$ref" ? "--reference $ref" : ""
    def in_deformation = "$deformation" ? "--in_deformation $deformation" : ""

    def inverse = task.ext.inverse ? "--inverse" : ""
    def reverse_operation = task.ext.reverse_operation ? "--reverse_operation" : ""
    def invalid_action = task.ext.invalid_action ? "--" + task.ext.invalid_action : "--remove_invalid"
    def no_empty1 = task.ext.no_empty1 ? "--no_empty" : ""
    def force = task.ext.force ? "-f" : ""

    def cut_invalid = task.ext.cut_invalid ? "--cut_invalid" : ""
    def remove_single_point = task.ext.remove_single_point ? "--remove_single_point" : ""
    def remove_overlapping_points = task.ext.remove_overlapping_points ? "--remove_overlapping_points" : ""
    def threshold = task.ext.threshold ? "--threshold " + task.ext.threshold : ""
    def no_empty2 = task.ext.no_empty2 ? "--no_empty" : ""

    """
    echo ${centroids_dir}
    for centroid in ${centroids_dir};
        do bname=\${centroid/_centroid/}
        bname=\$(basename \${bname} .trk)

        scil_apply_transform_to_tractogram.py \$centroid $anat $transfo tmp.trk\
                        $in_deformation\
                        $inverse\
                        $reverse_operation\
                        $invalid_action\
                        $no_empty1\
                        $force\
                        $reference

        scil_remove_invalid_streamlines.py tmp.trk ${prefix}__\${bname}.trk\
                        $cut_invalid\
                        $remove_single_point\
                        $remove_overlapping_points\
                        $threshold\
                        $no_empty2\
                        $reference\
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
    for centroid in ${centroids_dir};
        do bname=\${centroid/_centroid/}
        bname=\$(basename \${bname} .trk)

        touch ${prefix}__\${bname}.trk
    done

    scil_apply_transform_to_tractogram.py -h
    scil_remove_invalid_streamlines.py -h

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
