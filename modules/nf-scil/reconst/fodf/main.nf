
process RECONST_FODF {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
        tuple val(meta), path(dwi), path(bval), path(bvec), path(mask), path(fa), path(md), path(frf), val(method)

    output:
        tuple val(meta), path("*fodf.nii.gz")           , emit: fodf, optional: true
        tuple val(meta), path("*wm_fodf.nii.gz")        , emit: wm_fodf, optional: true
        tuple val(meta), path("*gm_fodf.nii.gz")        , emit: gm_fodf, optional: true
        tuple val(meta), path("*csf_fodf.nii.gz")       , emit: csf_fodf, optional: true
        tuple val(meta), path("*vf.nii.gz")             , emit: vf, optional: true
        tuple val(meta), path("*vf_rgb.nii.gz")         , emit: vf_rgb, optional: true
        tuple val(meta), path("*peaks.nii.gz")          , emit: peaks, optional: true
        tuple val(meta), path("*peak_values.nii.gz")    , emit: peak_values, optional: true
        tuple val(meta), path("*peak_indices.nii.gz")   , emit: peak_indices, optional: true
        tuple val(meta), path("*afd_max.nii.gz")        , emit: afd_max, optional: true
        tuple val(meta), path("*afd_total.nii.gz")      , emit: afd_total, optional: true
        tuple val(meta), path("*afd_sum.nii.gz")        , emit: afd_sum, optional: true
        tuple val(meta), path("*nufo.nii.gz")           , emit: nufo, optional: true
        path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    def dwi_shell_tolerance = task.ext.dwi_shell_tolerance ? "--tolerance " + task.ext.dwi_shell_tolerance : "" /* WARNING!!! Don't forget to add this back to compute_msmt_fodf once we get to scilpy 2.0. */
    def min_fodf_shell_value = task.ext.min_fodf_shell_value ?: 100     /* Default value for min_fodf_shell_value */
    def b0_thr_extract_b0 = task.ext.b0_thr_extract_b0 ?: 10        /* Default value for b0_thr_extract_b0 */
    def fodf_shells = task.ext.fodf_shells ?: "\$(cut -d ' ' --output-delimiter=\$'\\n' -f 1- $bval | awk -F' ' '{v=int(\$1)}{if(v>=$min_fodf_shell_value|| v<=$b0_thr_extract_b0)print v}' | uniq)"
    def sh_order = task.ext.sh_order ? "--sh_order " + task.ext.sh_order : ""
    def sh_basis = task.ext.sh_basis ? "--sh_basis " + task.ext.sh_basis : ""
    def set_method = method ?: "ssst_fodf"

    def relative_threshold = task.ext.relative_threshold ? "--rt " + task.ext.relative_threshold : ""
    def fodf_metrics_a_factor = task.ext.fodf_metrics_a_factor ? task.ext.fodf_metrics_a_factor : 2.0
    def fa_threshold = task.ext.fa_threshold ? "--fa_t " + task.ext.fa_threshold : ""
    def md_threshold = task.ext.md_threshold ? "--md_t " + task.ext.md_threshold : ""
    def abs_peaks_values = task.ext.abs_peaks_values ? "--abs_peaks_and_values" : ""

    def processes = task.ext.processes ? "--processes " + task.ext.processes : ""
    def set_mask = mask ? "--mask $mask" : ""

    if ( task.ext.wm_fodf ) wm_fodf = "--wm_out_fODF ${prefix}__wm_fodf.nii.gz" else wm_fodf = ""
    if ( task.ext.gm_fodf ) gm_fodf = "--gm_out_fODF ${prefix}__gm_fodf.nii.gz" else gm_fodf = ""
    if ( task.ext.csf_fodf ) csf_fodf = "--csf_out_fODF ${prefix}__csf_fodf.nii.gz" else csf_fodf = ""
    if ( task.ext.vf) vf = "--vf ${prefix}__vf.nii.gz" else vf = ""
    if ( task.ext.vf_rgb) vf_rgb = "--vf_rgb ${prefix}__vf_rgb.nii.gz" else vf_rgb = ""

    if ( task.ext.peaks ) peaks = "--peaks ${prefix}__peaks.nii.gz" else peaks = ""
    if ( task.ext.peak_values ) peak_values = "--peak_values ${prefix}__peak_values.nii.gz" else peak_values = ""
    if ( task.ext.peak_indices ) peak_indices = "--peak_indices ${prefix}__peak_indices.nii.gz" else peak_indices = ""
    if ( task.ext.afd_max ) afd_max = "--afd_max ${prefix}__afd_max.nii.gz" else afd_max = ""
    if ( task.ext.afd_total ) afd_total = "--afd_total ${prefix}__afd_total.nii.gz" else afd_total = ""
    if ( task.ext.afd_sum ) afd_sum = "--afd_sum ${prefix}__afd_sum.nii.gz" else afd_sum = ""
    if ( task.ext.nufo ) nufo = "--nufo ${prefix}__nufo.nii.gz" else nufo = ""

    if ( task.ext.peaks | task.ext.peak_values | task.ext.peak_indices | task.ext.afd_max | task.ext.afd_total | task.ext.afd_sum | task.ext.nufo ) do_metrics = true else do_metrics = false 

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
            $sh_order $sh_basis $set_mask $processes \
            --not_all $wm_fodf $gm_fodf $csf_fodf $vf $vf_rgb

        cp ${prefix}__wm_fodf.nii.gz ${prefix}__fodf.nii.gz

    fi

    if $do_metrics; then

        scil_compute_fodf_max_in_ventricles.py ${prefix}__fodf.nii.gz $fa $md \
            --max_value_output ventricles_fodf_max_value.txt $sh_basis \
            $fa_threshold $md_threshold -f

        a_factor=$fodf_metrics_a_factor
        v_max=\$(sed -E 's/([+-]?[0-9.]+)[eE]\\+?(-?)([0-9]+)/(\\1*10^\\2\\3)/g' <<<"\$(cat ventricles_fodf_max_value.txt)")
        a_threshold=\$(echo "scale=10; \${a_factor} * \${v_max}" | bc)
        if (( \$(echo "\${a_threshold} < 0" | bc -l) )); then
            a_threshold=0
        fi

        scil_compute_fodf_metrics.py ${prefix}__fodf.nii.gz \
            $set_mask $sh_basis --not_all \
            $peaks $peak_values $peak_indices \
            $afd_max $afd_total \
            $afd_sum $nufo \
            $relative_threshold --at \${a_threshold} \
            $processes $abs_peaks_values

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
    scil_compute_fodf_max_in_ventricles.py -h
    scil_compute_fodf_metrics.py -h

    touch ${prefix}__fodf.nii.gz
    touch ${prefix}__wm_fodf.nii.gz
    touch ${prefix}__gm_fodf.nii.gz
    touch ${prefix}__csf_fodf.nii.gz
    touch ${prefix}__vf.nii.gz
    touch ${prefix}__vf_rgb.nii.gz
    touch ${prefix}__peaks.nii.gz
    touch ${prefix}__peak_values.nii.gz
    touch ${prefix}__peak_indices.nii.gz
    touch ${prefix}__afd_max.nii.gz
    touch ${prefix}__afd_total.nii.gz
    touch ${prefix}__afd_sum.nii.gz
    touch ${prefix}__nufo.nii.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
