
process BETCROP_FSLBETCROP {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(dwi), path(bval), path(bvec)

    output:
        tuple val(meta), path("*dwi_bet_cropped.nii.gz")            , emit: dwi
        tuple val(meta), path("*dwi_bet_cropped_mask.nii.gz")       , emit: mask
        tuple val(meta), path("*dwi_boundingBox.pkl")               , emit: bbox
        path "versions.yml"                                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def b0_thr = task.ext.b0_thr ? "--b0_thr " + task.ext.b0_thr : ""
    def bet_dwi_f = task.ext.bet_dwi_f ? "-f " + task.ext.bet_dwi_f : ""

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    scil_extract_b0.py $dwi $bval $bvec ${prefix}__b0.nii.gz --mean \
        $b0_thr --force_b0_threshold
    bet ${prefix}__b0.nii.gz ${prefix}__b0_bet.nii.gz -m -R $bet_dwi_f
    scil_image_math.py convert ${prefix}__b0_bet_mask.nii.gz ${prefix}__b0_bet_mask.nii.gz --data_type uint8 -f
    mrcalc $dwi ${prefix}__b0_bet_mask.nii.gz -mult ${prefix}__dwi_bet.nii.gz -quiet -nthreads 1

    scil_crop_volume.py $dwi ${prefix}__dwi_bet_cropped.nii.gz -f \
        --output_bbox ${prefix}__dwi_boundingBox.pkl -f
    scil_crop_volume.py ${prefix}__b0_bet_mask.nii.gz ${prefix}__dwi_bet_cropped_mask.nii.gz -f\
        --input_bbox ${prefix}__dwi_boundingBox.pkl -f
    scil_image_math.py convert ${prefix}__dwi_bet_cropped_mask.nii.gz ${prefix}__dwi_bet_cropped_mask.nii.gz \
        --data_type uint8 -f

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
        mrtrix: \$(mrcalc -version 2>&1 | sed -n 's/== mrcalc \\([0-9.]\\+\\).*/\\1/p')
        fsl: \$(flirt -version 2>&1 | sed -n 's/FLIRT version \\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    scil_extract_b0.py -h
    bet -h
    scil_image_math.py -h
    mrcalc -h
    scil_crop_volume.py -h

    touch ${prefix}__dwi_bet_cropped.nii.gz
    touch ${prefix}__dwi_bet_cropped_mask.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
        mrtrix: \$(mrcalc -version 2>&1 | sed -n 's/== mrcalc \\([0-9.]\\+\\).*/\\1/p')
        fsl: \$(flirt -version 2>&1 | sed -n 's/FLIRT version \\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """
}
