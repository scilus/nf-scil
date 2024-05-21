process TRACTOGRAM_RESAMPLE {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.0.2.sif':
        'scilus/scilus:2.0.2' }"

    input:
        tuple val(meta), path(centroids)

    output:
        tuple val(meta), path("*_centroid_{*}.{trk,tck}")   , emit: centroids
        path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def nb_points = task.ext.nb_points ? "${task.ext.nb_points}" : "5"

    """
    for centroid in ${centroids};
        do
        ext=\${centroid#*.}

        if [[ \$centroid == *"__"* ]]; then
            pos=\$((\$(echo \$centroid | grep -b -o __ | cut -d: -f1)+2))
            bname=\${centroid:\$pos}
            bname=\$(basename \$bname .\${ext})
        else
            bname=\$(basename \$centroid .\${ext})
        fi
        bname=\${bname/_centroid/}
        bname=\${bname/_ic/}

        scil_tractogram_resample_nb_points.py \$centroid \
            "${prefix}__\${bname}_centroid_${nb_points}.\${ext}" \
            --nb_pts_per_streamline $nb_points -f
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 2.0.2
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    scil_tractogram_resample_nb_points.py -h

    for centroid in ${centroids};
        do \
        ext=\${centroid#*.}
        bname=\$(basename \${centroid} .\${ext})
        touch ${prefix}__\${bname}${suffix}.\${ext}
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 2.0.2
    END_VERSIONS
    """
}
