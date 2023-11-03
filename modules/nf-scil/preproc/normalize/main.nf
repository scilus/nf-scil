process PREPROC_NORMALIZE {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'scil.usherbrooke.ca/containers/scilus_1.5.0.sif':
        'scilus/scilus:1.5.0' }"

    input:
    tuple val(meta), path(dwi), path(mask), path(bval), path(bvec)
    path(dti_shells) /* optional, value = [] */

    output:
    tuple val(meta), path("*dwi_normalized.nii.gz")     , emit: dwi
    tuple val(meta), path("*fa_wm_mask.nii.gz")         , emit: mask
    path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args1 = task.ext.args1 ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def dti_info  = dti_shells ? "--dti_shells ${dti_shells}" : ""

    if (dti_info)
    """
    $task.cpus 3

    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    scil_extract_dwi_shell.py $dwi \
        $bval $bvec $dti_info dwi_dti.nii.gz \
        bval_dti bvec_dti -t $args1

    scil_compute_dti_metrics.py dwi_dti.nii.gz bval_dti bvec_dti --mask $mask \
        --not_all --fa fa.nii.gz --force_b0_threshold

    mrthreshold fa.nii.gz ${prefix}_fa_wm_mask.nii.gz \
        -abs $args2 -nthreads 1

    dwinormalise individual $dwi ${prefix}_fa_wm_mask.nii.gz \
        ${prefix}__dwi_normalized.nii.gz -fslgrad $bvec $bval -nthreads 1

    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            : \$(scil_get_version.py 2>&1)
    END_VERSIONS
    """

    else

    """
    $task.cpus 3

    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    shells=\$(cut -d ' ' --output-delimiter=\$'\\n' -f 1- $bval | awk -F' ' '{v=int(\$1)}{if(v<=$args3)print v}' | uniq)

    scil_extract_dwi_shell.py $dwi \
        $bval $bvec \$shells dwi_dti.nii.gz \
        bval_dti bvec_dti -t $args1

    scil_compute_dti_metrics.py dwi_dti.nii.gz bval_dti bvec_dti --mask $mask \
        --not_all --fa fa.nii.gz --force_b0_threshold

    mrthreshold fa.nii.gz ${prefix}_fa_wm_mask.nii.gz \
        -abs $args2 -nthreads 1

    dwinormalise individual $dwi ${prefix}_fa_wm_mask.nii.gz \
        ${prefix}__dwi_normalized.nii.gz -fslgrad $bvec $bval -nthreads 1

    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            : \$(scil_get_version.py 2>&1)
    END_VERSIONS
    """


    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    scil_extract_dwi_shell.py -h
    scil_compute_dti_metrics.py -h
    mrthreshold -h
    dwinormalise -h

    touch ${prefix}__dwi_normalized.nii.gz
    touch ${prefix}__fa_wm_mask.nii.gz

    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            : \$(scil_get_version.py 2>&1)
    END_VERSIONS
    """
}
