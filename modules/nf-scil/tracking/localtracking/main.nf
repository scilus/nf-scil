process TRACKING_LOCALTRACKING {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'biocontainers/scilus/scilus:1.6.0' }"

    input:
    tuple val(meta), path(fodf), path(tracking_mask), path(seed)

    output:
    tuple val(meta), path("*__local_tracking.trk"), emit: trk
    tuple val(meta), path("*__local_tracking_config.json"), emit: config
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def local_step = task.ext.local_step ? "--step" + task.ext.local_step : ""
    def local_random_seed = task.ext.local_random_seed ? "--seed" + task.ext.local_random_seed : ""
    def local_seeding = task.ext.local_seeding ? "--" + task.ext.local_seeding : ""
    def local_nbr_seed = task.ext.local_nbr_seed ? "--" + task.ext.local_nbr_seed : ""
    def local_min_len = task.ext.min_len ? "--min_length" + task.ext.min_len : ""
    def local_max_len = task.ext.max_len ? "--max_length" + task.ext.max_len : ""
    def local_theta = task.ext.local_theta ? "--theta "  + task.ext.local_theta : ""
    def local_sfthres = task.ext.local_sfthres ? "--sfthres "  + task.ext.local_sfthres : ""
    def local_algo = task.ext.local_algo ? "--algo " + task.ext.local_algo: ""
    def basis = task.ext.basis ? "--sh_basis " + task.ext.basis : ""
    def sphere = task.ext.sphere ? "--sphere" + task.ext.sphere : ""

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    scil_compute_local_tracking.py $fodf $seed $tracking_mask tmp.trk\
            $local_algo $local_seeding $local_nbr_seeds\
            $local_random_seed $local_step $local_theta\
            $local_sfthres $local_min_len\
            $local_max_len $compress $basis

    scil_remove_invalid_streamlines.py tmp.trk\
            ${prefix}__local_tracking.trk\
            --remove_single_point

    cat <<-TRACKING_INFO > ${prefix}__local_tracking_config.json
    {"algorithm": "${task.ext.local_algo}",
    "seeding_type": "${task.ext.local_seeding}",
    "nb_seed": $task.ext.local_nbr_seeds,
    "seeding_mask": "${task.ext.local_seeding_mask_type}",
    "random_seed": $task.ext.local_random_seed,
    "is_compress": "${task.ext.local_compress_streamlines}",
    "compress_value": $task.ext.local_compress_value,
    "step": $task.ext.local_step,
    "theta": $task.ext.local_theta,
    "sfthres": $task.ext.local_sfthres,
    "min_len": $task.ext.local_min_len,
    "max_len": $task.ext.local_max_len,
    "sphere": ${task.ext.sphere},
    "sh_basis": "${task.ext.basis}"}
    TRACKING_INFO

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    scil_compute_local_tracking.py -h
    scil_remove_invalid_streamlines.py -h

    touch ${prefix}__local_tracking.trk
    touch ${prefix}__local_tracking_config.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
