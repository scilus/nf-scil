process IMAGE_RESAMPLE {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
    tuple val(meta), path(image)

    output:
    tuple val(meta), path("*_resampled.nii.gz"), emit: image
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def voxel_size = task.ext.voxel_size ? "--voxel_size " + task.ext.voxel_size : ""
    def interp = task.ext.interp ? "--interp " + task.ext.interp : ""
    def volume_size = task.ext.volume_size ? "--volume_size " + task.ext.volume_size : ""
    def ref = task.ext.ref ? "--ref" + task.ext.ref : ""
    def iso_min = task.ext.iso_min ? "--iso_min" + task.ext.iso_min : ""
    def enforce_dimensions = task.ext.enforce_dimensions ? "--enforce_dimensions" + task.ext.enforce_dimensions : ""
    def f = task.ext.f ? "--f" + task.ext.f : ""

    def resampling_method = task.ext.voxel_size ? "--voxel_size " + task.ext.voxel_size : (task.ext.volume_size ? "--volume_size " + task.ext.volume_size : "")

"""
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1
    scil_resample_volume.py $resampling_method \
        $interp \
        $iso_min \
        $image ${prefix}__resampled.nii.gz \
 
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    scil_resample_volume.py -h

    touch ${prefix}__resampled.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
