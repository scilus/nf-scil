
process RECONST_FODF {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(dwi), path(bval), path(bvec), path(mask), path(frf)

    output:
        tuple val(meta), path("*fodf.nii.gz")           , emit: fodf
        path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def dwi_shell_tolerance = task.ext.dwi_shell_tolerance ? "--tolerance " + task.ext.dwi_shell_tolerance : ""
    def fodf_shells = task.ext.fodf_shells ?: "\$(cut -d ' ' --output-delimiter=\$'\\n' -f 1- $bval | awk -F' ' '{v=int(\$1)}{if(v>=$task.ext.min_fodf_shell_value|| v<=$task.ext.b0_thr_extract_b0)print v}' | uniq)"
    def sh_order = task.ext.sh_order ? "--sh_order " + task.ext.sh_order : ""
    def sh_basis = task.ext.sh_basis ? "--sh_basis " + task.ext.sh_basis : ""
    def processes = task.ext.processes ? "--processes " + task.ext.processes : ""
    def set_mask = mask ? "--mask $mask" : ""

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    scil_extract_dwi_shell.py $dwi $bval $bvec $fodf_shells \
        dwi_fodf_shells.nii.gz bval_fodf_shells bvec_fodf_shells \
        $dwi_shell_tolerance -f

    scil_compute_ssst_fodf.py dwi_fodf_shells.nii.gz bval_fodf_shells bvec_fodf_shells $frf ${prefix}__fodf.nii.gz \
        $sh_order $sh_basis --force_b0_threshold \
        $set_mask $processes

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    scil_extract_dwi_shell.py -h
    scil_compute_ssst_fodf.py -h

    touch ${prefix}__fodf.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
