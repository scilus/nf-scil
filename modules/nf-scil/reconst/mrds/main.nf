process RECONST_MRDS {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'biocontainers/YOUR-TOOL-HERE' }"

    input:
        tuple val(meta), path(dwi), path(bval), path(bvec), path(nufo), path(mask),

    output:
        tuple val(meta), path("*mrds_fa.nii.gz"), emit: mrds_fa
        tuple val(meta), path("*mrds_ad.nii.gz"), emit: mrds_ad
        tuple val(meta), path("*mrds_rd.nii.gz"), emit: mrds_rd
        tuple val(meta), path("*mrds_md.nii.gz"), emit: mrds_md
        tuple val(meta), path("*_MRDS_EIGENVALUES"), emit: mrds_eigenvalues
        tuple val(meta), path("*__scheme.b"), emit: scheme
        path("*fodf.nii.gz")           , emit: fodf, optional: true
        path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def iso = task.ext.iso ? "--iso" : ""
    """
        scil_convert_gradients_fsl_to_mrtrix.py ${bval} ${bvec} ${prefix}__scheme.b
        scil_mrds_modsel_todi.py ${nufo} ${dwi} \
            --N1 ${n1_compsize} ${n1_eigen} ${n1_iso} ${n1_numcomp} ${n1_pdds} \
            --N2 ${n2_compsize} ${n2_eigen} ${n2_iso} ${n2_numcomp} ${n2_pdds} \
            --N3 ${n3_compsize} ${n3_eigen} ${n3_iso} ${n3_numcomp} ${n3_pdds} \
            --prefix ${prefix} \
            --mask ${mask}

        mdtmrds ${dwi} ${scheme} ${prefix} -correction 0 -response %.12f,%.12f,0.003 %s -modsel ${modsel} -each -intermediate %s -mse -method %s' % (dwi, scheme, prefix, d_par, d_perp, mask, modsel, iso, method)

        scil_compute_mrds_metrics.py ${prefix}_MRDS_EIGENVALUES.nii.gz --mask $mask --not_all \
            --fa ${prefix}_mrds_fa.nii.gz \
            --ad ${prefix}_mrds_ad.nii.gz \
            --rd ${prefix}_mrds_rd.nii.gz \
            --md ${prefix}_mrds_md.nii.gz -f

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 2.0.2
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        reconst: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
