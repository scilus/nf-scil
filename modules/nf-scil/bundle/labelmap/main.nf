
process BUNDLE_LABEL_AND_DISTANCE_MAPS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(bundles), path(centroids)

    output:
    tuple val(meta), path("*_labels.nii.gz")    , emit: label
    tuple val(meta), path("*_labels.trk")       , emit: label_trk
    tuple val(meta), path("*_distances.nii.gz") , emit: distances
    tuple val(meta), path("*_distances.trk")    , emit: distances_trk
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def nb_points = task.ext.nb_points ?: ''

    String bundles_list = bundles.join(", ").replace(',', '')
    """
    for bundle in $bundles_list;
        do if [[ \$bundle == *"__"* ]]; then
            pos=\$((\$(echo \$bundle | grep -b -o __ | cut -d: -f1)+2))
            bname=\${bundle:\$pos}
            bname=\$(basename \$bname .trk)
        else
            bname=\$(basename \$bundle .trk)
        fi
        bname=\${bname/_ic/}

        centroid=${prefix}__\${bname}_centroid_${nb_points}.trk
        if [[ -f \${centroid} ]]; then
            scil_bundle_label_map.py \$bundle \${centroid} tmp_out -f

            mv tmp_out/labels_map.nii.gz ${prefix}__\${bname}_labels.nii.gz
            mv tmp_out/distance_map.nii.gz ${prefix}__\${bname}_distances.nii.gz

            mv tmp_out/labels.trk ${prefix}__\${bname}_labels.trk
            mv tmp_out/distance.trk ${prefix}__\${bname}_distances.trk
        fi

    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    scil_bundle_label_map.py -h
    touch ${prefix}__bundlename_labels.nii.gz
    touch ${prefix}__bundlename_labels.trk
    touch ${prefix}__bundlename_distances.nii.gz
    touch ${prefix}__bundlename_distances.trk

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
