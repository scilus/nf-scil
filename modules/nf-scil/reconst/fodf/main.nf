
process RECONST_FODF {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(dwi), path(bval), path(bvec), path(mask), path(frf), path(method)

    output:
        tuple val(meta), path("*fodf.nii.gz")           , emit: fodf, optional: true
        tuple val(meta), path("*wm_fodf.nii.gz")        , emit: wm_fodf, optional: true
        tuple val(meta), path("*gm_fodf.nii.gz")        , emit: gm_fodf, optional: true
        tuple val(meta), path("*csf_fodf.nii.gz")       , emit: csf_fodf, optional: true
        tuple val(meta), path("*vf.nii.gz")             , emit: vf, optional: true
        tuple val(meta), path("*vf_rgb.nii.gz")         , emit: vf_rgb, optional: true
        path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def dwi_shell_tolerance = task.ext.dwi_shell_tolerance ? "--tolerance " + task.ext.dwi_shell_tolerance : ""
    def min_fodf_shell_value = task.ext.min_fodf_shell_value ?: 100     /* Default value for min_fodf_shell_value */
    def b0_thr_extract_b0 = task.ext.b0_thr_extract_b0 ?: 10        /* Default value for b0_thr_extract_b0 */
    def fodf_shells = task.ext.fodf_shells ?: "\$(cut -d ' ' --output-delimiter=\$'\\n' -f 1- $bval | awk -F' ' '{v=int(\$1)}{if(v>=$min_fodf_shell_value|| v<=$b0_thr_extract_b0)print v}' | uniq)"
    def sh_order = task.ext.sh_order ? "--sh_order " + task.ext.sh_order : ""
    def sh_basis = task.ext.sh_basis ? "--sh_basis " + task.ext.sh_basis : ""
    def processes = task.ext.processes ? "--processes " + task.ext.processes : ""
    def set_mask = mask ? "--mask $mask" : ""
    def set_method = method ?: "ssst_fodf"

    if ( task.ext.wm_fodf ) wm_fodf = "--wm_out_fODF ${prefix}__wm_fodf.nii.gz" else wm_fodf = ""
    if ( task.ext.gm_fodf ) gm_fodf = "--gm_out_fODF ${prefix}__gm_fodf.nii.gz" else gm_fodf = ""
    if ( task.ext.csf_fodf ) csf_fodf = "--csf_out_fODF ${prefix}__csf_fodf.nii.gz" else csf_fodf = ""
    if ( task.ext.vf) vf = "--vf ${prefix}__vf.nii.gz" else vf = ""
    if ( task.ext.vf_rgb) vf_rgb = "--vf_rgb ${prefix}__vf_rgb.nii.gz" else vf_rgb = ""

    """
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
    export OMP_NUM_THREADS=1
    export OPENBLAS_NUM_THREADS=1

    if [ "$set_method" = "ssst_fodf" ]; then

    scil_extract_dwi_shell.py $dwi $bval $bvec $fodf_shells \
        dwi_fodf_shells.nii.gz bval_fodf_shells bvec_fodf_shells \
        $dwi_shell_tolerance -f

    scil_compute_ssst_fodf.py dwi_fodf_shells.nii.gz bval_fodf_shells bvec_fodf_shells $frf ${prefix}__fodf.nii.gz \
        $sh_order $sh_basis --force_b0_threshold \
        $set_mask $processes

    fi

    if [ "$set_method" = "msmt_fodf" ]; then

    scil_extract_dwi_shell.py $dwi $bval $bvec $fodf_shells \
        dwi_fodf_shells.nii.gz bval_fodf_shells bvec_fodf_shells \
        $dwi_shell_tolerance -f

    scil_compute_msmt_fodf.py dwi_fodf_shells.nii.gz bval_fodf_shells bvec_fodf_shells $frf \
        $sh_order $sh_basis --tolerance $dwi_shell_tolerance $set_mask $processes \
        --not_all $wm_fodf $gm_fodf $csf_fodf $vf $vf_rgb

    fi

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
    scil_compute_msmt_fodf.py -h

    touch ${prefix}__fodf.nii.gz
    touch ${prefix}__wm_fodf.nii.gz
    touch ${prefix}__gm_fodf.nii.gz
    touch ${prefix}__csf_fodf.nii.gz
    touch ${prefix}__vf.nii.gz
    touch ${prefix}__vf_rgb.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
