
process TESTDATA_SCILPY {
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    input:
    val(archive)
    path(test_data_path)

    output:
    path("test_data/${archive.take(archive.lastIndexOf('.'))}"), emit: test_data_directory
    path "versions.yml"                                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def remote = "https://scil.usherbrooke.ca"
    def database = "scil_test_data/dvc-store/files/md5"
    def data_associations = [
        commit_amico.zip: "c190e6b9d22350b51e222c60febe13b4",
        bundles.zip: "6d3ebc21062bf320714483b7314a230a",
        stats.zip: "2aeac4da5ab054b3a460fc5fdc5e4243",
        bst.zip: "eed227fd246255e7417f92d49eb1066a",
        filtering.zip: "19116ff4244d057c8214ee3fe8e05f71",
        ihMT.zip: "08fcf44848ba2649aad5a5a470b3cb06",
        tractometry.zip: "890bfa70e44b15c0d044085de54e00c6",
        bids_json.zip: "97fd9a414849567fbfdfdb0ef400488b",
        MT.zip: "1f4345485248683b3652c97f2630950e",
        btensor_testdata.zip: "7ada72201a767292d56634e0a7bbd9ad",
        tracking.zip: "4793a470812318ce15f1624e24750e4d",
        atlas.zip: "dc34e073fc582476504b3caf127e53ef",
        anatomical_filtering.zip: "5282020575bd485e15d3251257b97e01",
        connectivity.zip: "fe8c47f444d33067f292508d7050acc4",
        plot.zip: "a1dc54cad7e1d17e55228c2518a1b34e",
        others.zip: "82248b4888a63b0aeffc8070cc206995",
        fodf_filtering.zip: "5985c0644321ecf81fd694fb91e2c898",
        processing.zip: "eece5cdbf437b8e4b5cb89c797872e28",
        surface_vtk_fib.zip: "241f3afd6344c967d7176b43e4a99a41",
        tractograms.zip: "5497d0bf3ccc35f8f4f117829d790267",
        registration.zip: "95ebaa64866bac18d8b0fcd96cd10958",
        topup_eddy.zip: "7847496510dc85fb205ba9586f0011ff",
        topup_eddy_light.zip: "54369410cfd0587e1d8916047945c1fd",
        bids.zip: "68b9efa1e009a59a83adef3aeea9b469",
        antsbet.zip: "66850bea7af7c1f3fc4e7d371d12d6e8",
        freesurfer.zip: "3b876fba6fd77d4962243ac9647bc505",
        light.zip: "f2a3a8bddf43d1f67a5e8867ce9ebaa2",
        heavy.zip: "6f2cd0bbdb162455e71de1c7d3b4eb18"
    ]

    storage = file("$XDG_CONFIG_PATH/nf-scil-test-archives")
    if ( !storage.exists() ) storage.mkdirs()

    resource = file("$storage/${data_associations[archive]}")
    if ( !resource.exists() ) {
        resource = file("$remote/$database/${data_associations[archive]}")
            .moveTo("$resource")
    }
    """
    mkdir -p $test_data_path
    cd $test_data_path
    unzip $resource
    """

    stub:
    def args = task.ext.args ?: ''
    """
    mkdir -p test_data/${file(archive).simpleName}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scilpy: 1.6.0
    END_VERSIONS
    """
}
