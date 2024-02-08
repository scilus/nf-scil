process IO_READBIDS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
    path(bids_folder), path(fs_folder) ,path(bidsignore)


    output:
    path("tractoflow_bids_struct.json"), emit: bids
    path "versions.yml"                             , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def clean_flag = task.ext.clean_bids ? '--clean ' : ''
    def readout = task.ext.readout ? '--readout ' : ''
    """
    scil_validate_bids.py $bids_folder tractoflow_bids_struct.json\
        --readout $params.readout $clean_flag\
        ${!fs_folder.empty() ? "--fs $fs_folder" : ""}\
        ${!bidsignore.empty() ? "--bids_ignore $bidsignore" : ""}\
        -v



    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """


    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    scil_validate_bids.py -h

    touch ${prefix}__tractoflow_bids_struct.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
