process BUNDLE_UNIFORMIZE {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.0.0.sif':
        'scilus/scilus:2.0.2' }"

    input:
    tuple val(meta), path(bundles), path(centroids)/* optional*/, path(ref)/* optional*/

    output:
    tuple val(meta), path("*_uniformized.trk"), emit: bundles
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def method = task.ext.method ? "--${task.ext.method}"  : "--auto"
    def reference = "$ref" ? "--reference $ref" : ""
    def swap = task.ext.swap ? "--swap" : ""
    def force = task.ext.force ? "-f" : ""

    """
    bundles=(${bundles.join(" ")})

    if [[ "$method" == "--centroid" ]]; then
        centroids=(${centroids.join(" ")})
    fi

    for index in \${!bundles[@]};
        do \
        bname=\$(basename \${bundles[index]} .trk)
        if [[ "$method" == "--centroid" ]]; then
            scil_bundle_uniformize_endpoints.py \${bundles[index]} ${prefix}__\${bname}_uniformized.trk\
                $method \${centroids[index]}\
                $reference\
                $swap\
                $force
        else
            scil_bundle_uniformize_endpoints.py \${bundles[index]} ${prefix}__\${bname}_uniformized.trk\
                $method\
                $reference\
                $swap\
                $force
        fi
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 2.0.2
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
 """
    scil_bundle_uniformize_endpoints.py -h

    for bundles in ${bundles};
        do \
        bname=\$(basename \${bundles} .trk)
        touch ${prefix}__\${bname}_uniformized.trk
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 2.0.2
    END_VERSIONS
    """
}
