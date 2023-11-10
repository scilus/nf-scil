
process BETCROP_FSLBETCROP {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(dwi), path(bval), path(bvec), path(mask)
        path(kernels)

    output:
        tuple val(meta), path("*__FIT_dir.nii.gz")              , emit: dir
        tuple val(meta), path("*__FIT_ISOVF.nii.gz")            , emit: isovf
        tuple val(meta), path("*__FIT_ICVF.nii.gz")             , emit: icvf
        tuple val(meta), path("*__FIT_OD.nii.gz")               , emit: od
        path "versions.yml"                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def para_diff = task.ext.para_diff ? "--para_diff " + task.ext.para_diff : ""
    def iso_diff = task.ext.iso_diff ? "--iso_diff " + task.ext.iso_diff : ""
    def lambda1 = task.ext.lambda1 ? "--lambda1 " + task.ext.lambda1 : ""
    def lambda2 = task.ext.lambda2 ? "--lambda2 " + task.ext.lambda2 : ""
    def nb_threads = task.ext.nb_threads ? "--processes " + task.ext.nb_threads : ""
    def b_thr = task.ext.b_thr ? "--b_thr " + task.ext.b_thr : ""

    def set_kernels = []
    if (kernels)
        set_kernels += ["--load_kernels + $kernels"]
    else
        set_kernels += ["--save_kernels kernels/ --compute_only":]

    def set_mask = []
    if (mask) set_mask += ["--mask $mask"]

    """
    scil_compute_NODDI.py $dwi $bval $bvec $set_mask\
        $para_diff $iso_diff $lambda1 $lambda2 $nb_threads $b_thr\
        $set_kernels

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    scil_compute_NODDI.py -h

    touch "${prefix}__FIT_dir.nii.gz"
    touch "${prefix}__FIT_ISOVF.nii.gz"
    touch "${prefix}__FIT_ICVF.nii.gz"
    touch "${prefix}__FIT_OD.nii.gz"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
