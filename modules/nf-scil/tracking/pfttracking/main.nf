

process TRACKING_PFTTRACKING {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(fodf), path(seed), path(include), path(exclude)

    output:
        tuple val(meta), path("*.trk")            , emit: trk
        path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def pft_random_seed =  task.ext.pft_random_seed ?: "--"
    def compress = task.ext.pft_compress_streamlines ? "--compress " + task.ext.pft_compress_value : ""
    def pft_algo = task.ext.pft_algo ? "--algo " + task.ext.pft_algo: ""
    def pft_seeding_type = task.ext.pft_seeding ? "--"  + task.ext.pft_seeding : ""
    def pft_nbr_seeds = task.ext.pft_nbr_seeds ? "-- "  + task.ext.pft_nbr_seeds : ""
    def pft_step = task.ext.pft_step ? "--step "  + task.ext.pft_step : ""
    def pft_seeding_mask = task.ext.pft_seeding_mask_type ? "--"  + task.ext.pft_seeding_mask_type : ""
    def pft_theta = task.ext.pft_theta ? "--theta "  + task.ext.pft_theta : ""
    def pft_sfthres = task.ext.pft_sfthres ? "--sfthres "  + task.ext.pft_sfthres : ""
    def pft_sfthres_init = task.ext.pft_sfthres_init ? "--sfthres_init "  + task.ext.pft_sfthres_init : ""
    def pft_min_len = task.ext.pft_min_len ? "--min_length "  + task.ext.pft_min_len : ""
    def pft_max_len = task.ext.pft_max_len ? "--max_length "  + task.ext.pft_max_len : ""
    def pft_particles = task.ext.pft_particles ? "--particles "  + task.ext.pft_particles : ""
    def pft_back = task.ext.pft_back ? "--back "  + task.ext.pft_back : ""
    def pft_front = task.ext.pft_front ? "--forward "  + task.ext.pft_front : ""
    def basis = task.ext.basis ? "--sh_basis "  + task.ext.basis : ""

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    scil_compute_pft.py $fodf $seed $include $exclude tmp.trk\
        --algo $pft_algo --$pft_seeding_type $pft_nbr_seeds \
        --seed $pft_random_seed --step $pft_step --theta $pft_theta\
        --sfthres $pft_sfthres --sfthres_init $pft_sfthres_init\
        --min_length $pft_min_len --max_length $pft_max_len\
        --particles $pft_particles --back $pft_back\
        --forward $pft_front $compress --sh_basis $basis

    scil_remove_invalid_streamlines.py tmp.trk\
        ${prefix}__pft_tracking_${pft_algo}_${pft_seeding_mask}_seed_${pft_random_seed}.trk\
        --remove_single_point

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    scil_compute_pft.py -h
    scil_remove_invalid_streamlines.py -h

    touch ${prefix}__pft_tracking_${pft_algo}_${pft_seeding_mask}_seed_${pft_random_seed}.trk

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
