process BUNDLE_STATS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.0.2.sif':
        'scilus/scilus:2.0.2' }"

    input:
    tuple val(meta), path(bundles), path(metrics), path(endpoints_head), path(endpoint_tail), path(voxel_labels_map), path(labels_map), path(distance_map)

    output:
    tuple val(meta), path("*__length_stats.json")          , emit: length
    tuple val(meta), path("*__endpoints_map_raw.json")     , emit: endpoints_raw
    tuple val(meta), path("*__endpoints_metric_stats.json"), emit: endpoints_metric_stats
    tuple val(meta), path("*__mean_std.json")              , emit: mean_std
    tuple val(meta), path("*__volume.json")                , emit: volume
    tuple val(meta), path("*__streamline_count.json")      , emit: streamline_count
    tuple val(meta), path("*__volume_per_label.json")      , emit: volume_per_labels
    tuple val(meta), path("*__mean_std_per_point.json")    , emit: mean_std_per_point
    tuple val(meta), path("*_endpoints_map_head.nii.gz")   , emit: endpoints_head
    tuple val(meta), path("*_endpoints_map_tail.nii.gz")   , emit: endpoints_tail
    tuple val(meta), path("*_endpoints_metric.nii.gz")     , emit: endpoints_metric
    path "versions.yml"                                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    for bundle in $bundles;
        bname=\$(basename \$bundle .trk)
        b_metrics="$metrics"
        b_metrics=\$(echo \$b_metrics | tr ' ' '\n' | grep -v "_afd_metric" | tr '\n' ' ')

        if [[ -f \${bname}_ic_afd_metric.nii.gz ]];
        then
            mv \${bname}_ic_afd_metric.nii.gz afd_metric.nii.gz
            b_metrics+=" afd_metric.nii.gz"
        fi

        scil_compute_streamlines_length_stats.py \$bundle > \$bname_lenght.json

        scil_compute_endpoints_map.py \$bname.trk \
            ${prefix}__\${bname}_endpoints_map_head.nii.gz \
            ${prefix}__\${bname}_endpoints_map_tail.nii.gz >\
            ${prefix}__\${bname}_endpoints_raw.json

        scil_compute_metrics_stats_in_ROI.py \${bname}_head.nii.gz $normalize_weights\
            --metrics \${b_metrics} > \${bname}_head.json
        scil_compute_metrics_stats_in_ROI.py \${bname}_tail.nii.gz $normalize_weights\
            --metrics \${b_metrics} > \${bname}_tail.json

        scil_compute_bundle_mean_std.py $density_weighting \$bname.trk \${b_metrics} >\
            \${bname}_std.json

        scil_compute_bundle_volume.py \$bname.trk > \${bname}_volume.json

    done

    scil_merge_json.py *_lenght.json ${prefix}__length_stats.json --add_parent_key ${prefix} \
            --keep_separate

    scil_merge_json.py *_endpoints_raw.json ${prefix}__endpoints_map_raw.json \
        --no_list --add_parent_key ${prefix}

    scil_merge_json.py *_tail.json *_head.json ${prefix}__endpoints_metric_stats.json \
        --no_list --add_parent_key ${prefix}

    scil_merge_json.py *_std.json ${sid}__mean_std.json --no_list --add_parent_key ${sid}

    scil_merge_json.py *_volume.json ${sid}__volume.json --no_list --add_parent_key ${sid}

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
