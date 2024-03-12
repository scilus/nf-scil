process BETCROP_SYNTHBET {
    tag "$meta.id"
    label 'process_single'

    container "freesurfer/synthstrip:latest"

    input:
    tuple val(meta), path(t1), path(fs_license) /* optional, value = [] */

    output:
    tuple val(meta), path("*__t1_bet.nii.gz"), emit: bet_t1
    tuple val(meta), path("*__t1_bet_mask.nii.gz"), emit: mask
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    def gpu = task.ext.gpu ? "--gpu" : ""
    def border = task.ext.border ? "-b" + task.ext.border : ""
    def nocsf = task.ext.nocsf ? "--no-csf" : ""

    """
    # Manage the license. (Save old one if existed.)
    if [ $fs_license = [] ]; then
        echo "License not given in input. Using default environment. "
    else
        cp $fs_license .license
        here=`pwd`
        export FS_LICENSE=\$here/.license
    fi

    # Run the main script
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$task.cpus
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    export SUBJECTS_DIR=`pwd`

    mri_synthstrip --image $t1 --out ${prefix}__t1_bet.nii.gz --mask ${prefix}__t1_bet_mask.nii.gz $gpu $border $nocsf
    #scil_image_math.py convert temp_mask.nii.gz ${prefix}__t1_bet_mask.nii.gz --data_type uint8

    # Remove the license
    if [ ! $fs_license = [] ]; then
        rm .license
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
        freesurfer: 7.4
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mri_synthstrip -h
    scil_image_math.py -h

    touch ${prefix}__t1_bet.nii.gz
    touch ${prefix}__t1_bet_mask.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
        freesurfer: 7.4
    END_VERSIONS
    """
}
