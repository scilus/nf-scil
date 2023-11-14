

process RECONST_DIFFUSIVITYPRIORS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(fa), path(ad), path(md), path(priors)

    output:
        tuple val(meta), path("*para_diff.txt")     , emit: para_diff, optional: true
        tuple val(meta), path("*iso_diff.txt")      , emit: iso_diff, optional: true
        path("priors")                              , emit: priors, optional: true
        path("mean_para_diff.txt")                  , emit: mean_para_diff, optional: true
        path("mean_iso_diff.txt")                   , emit: mean_iso_diff, optional: true
        path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def fa_min = task.ext.fa_min ? "--fa_min " + task.ext.fa_min : ""
    def fa_max = task.ext.fa_max ? "--fa_max " + task.ext.fa_max : ""
    def md_min = task.ext.md_min ? "--md_min " + task.ext.md_min : ""
    def roi_radius = task.ext.roi_radius ? "--roi_radius " + task.ext.roi_radius : ""

    """
    if [ ! -z "$priors" ]
    then
        cat $priors/*_para_diff.txt > all_para_diff.txt
        awk '{ total += \$1; count++ } END { print total/count }' all_para_diff.txt > mean_para_diff.txt
        cat $priors/*_iso_diff.txt > all_iso_diff.txt
        awk '{ total += \$1; count++ } END { print total/count }' all_iso_diff.txt > mean_iso_diff.txt

    else

        mkdir priors
        scil_compute_NODDI_priors.py $fa $ad $md $fa_min $fa_max $md_min $roi_radius\
        --out_txt_1fiber priors/${prefix}__para_diff.txt\
        --out_txt_ventricles priors/${prefix}__iso_diff.txt
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    scil_compute_NODDI_priors.py -h

    mkdir priors
    touch priors/${prefix}__para_diff.txt
    touch priors/${prefix}__iso_diff.txt

    touch "mean_para_diff.txt"
    touch "mean_iso_diff.txt"


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
