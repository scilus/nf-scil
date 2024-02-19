
process BETCROP_FSLBETCROP {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(image), path(bval), path(bvec)

    output:
        tuple val(meta), path("*_bet.nii.gz")            , emit: image
        tuple val(meta), path("*_bet_mask.nii.gz")       , emit: mask
        tuple val(meta), path("*_boundingBox.pkl")               , emit: bbox , optional: true
        path "versions.yml"                                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def b0_thr = task.ext.b0_thr ? "--b0_thr " + task.ext.b0_thr : ""
    def bet_f = task.ext.bet_f ? "-f " + task.ext.bet_f : ""

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    if [ -v "$bval" ]
    then
        scil_extract_b0.py $image $bval $bvec ${prefix}__b0.nii.gz --mean \
            $b0_thr --force_b0_threshold

        bet ${prefix}__b0.nii.gz ${prefix}__b0_bet.nii.gz -m -R $bet_f
        scil_image_math.py convert ${prefix}__b0_bet_mask.nii.gz ${prefix}__b0_bet_mask.nii.gz --data_type uint8 -f
        mrcalc $image ${prefix}__b0_bet_mask.nii.gz -mult ${prefix}__dwi_bet.nii.gz -quiet -nthreads 1

        if [ "$task.ext.crop" = "true" ];
        then
            scil_crop_volume.py ${prefix}__dwi_bet.nii.gz ${prefix}__dwi_bet_cropped.nii.gz -f \
                --output_bbox ${prefix}__dwi_boundingBox.pkl -f
            scil_crop_volume.py ${prefix}__b0_bet_mask.nii.gz ${prefix}__dwi_bet_cropped_mask.nii.gz -f\
                --input_bbox ${prefix}__dwi_boundingBox.pkl -f
            scil_image_math.py convert ${prefix}__dwi_bet_cropped_mask.nii.gz ${prefix}__dwi_bet_cropped_mask.nii.gz \
                --data_type uint8 -f
        fi

    else
        bet $image ${prefix}__t1_bet.nii.gz -m -R $bet_f
        scil_image_math.py convert ${prefix}__t1_bet_mask.nii.gz ${prefix}__t1_bet_mask.nii.gz --data_type uint8 -f

        if [ "$task.ext.crop" = "true" ];
        then
            scil_crop_volume.py ${prefix}__t1_bet.nii.gz ${prefix}__t1_bet_cropped.nii.gz -f \
                --output_bbox ${prefix}__t1_boundingBox.pkl -f
            scil_crop_volume.py ${prefix}__t1_bet_mask.nii.gz ${prefix}__t1_bet_cropped_mask.nii.gz -f\
                --input_bbox ${prefix}__t1_boundingBox.pkl -f
            scil_image_math.py convert ${prefix}__t1_bet_cropped_mask.nii.gz ${prefix}__t1_bet_cropped_mask.nii.gz \
                --data_type uint8 -f
        fi
    fi

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
    touch ${prefix}__dwi_boundingBox.pkl

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
        mrtrix: \$(mrcalc -version 2>&1 | sed -n 's/== mrcalc \\([0-9.]\\+\\).*/\\1/p')
        fsl: \$(flirt -version 2>&1 | sed -n 's/FLIRT version \\([0-9.]\\+\\)/\\1/p')
    END_VERSIONS
    """
}
