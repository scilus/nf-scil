

process TESTDATA_SCILPY {
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
    val(archive)
    path(test_data_path)

    output:
    path("$test_data_path/${archive.take(archive.lastIndexOf('.'))}"), emit: test_data_directory
    path "versions.yml"                                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    export SCILPY_HOME="$test_data_path"

    python - << EOF
    from scilpy.io.fetcher import fetch_data, get_testing_files_dict

    fetch_data(get_testing_files_dict(), keys=["$archive"])

    EOF

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}