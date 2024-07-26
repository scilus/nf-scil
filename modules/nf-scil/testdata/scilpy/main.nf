
process TESTDATA_SCILPY {
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_2.0.2.sif':
        'scilus/scilus:2.0.2' }"

    input:
    val(archive)
    path(test_data_path)

    output:
    path("${archive.take(archive.lastIndexOf('.'))}") , emit: test_data_directory

    when:
    task.ext.when == null || task.ext.when

    exec:
    def remote = params.nf_scil_test_data_remote
    def database = params.nf_scil_test_database_path
    def data_associations = params.nf_scil_test_data_associations

    def data_home = file(
        System.getenv('XDG_DATA_HOME') ?: "${System.getenv('HOME')}/.local/share"
    )
    def storage = file("$data_home/nf-scil-test-archives")
    if ( !storage.exists() ) storage.mkdirs()

    def resource = file("$storage/${data_associations[archive]}")
    if ( !resource.exists() ) {
        def location = "${data_associations[archive][0..1]}/${data_associations[archive][2..-1]}"
        file("$remote/$database/$location").copyTo(resource)
    }

    def dest = task.workDir
    if ( !test_data_path.isEmpty() ) {
        dest = file("${task.workDir}/${test_data_path.getName()}")
        if ( !dest.exists() ) {
            test_data_path.mklink(dest)
        }
    }
    dest = dest.resolve("${archive.take(archive.lastIndexOf('.'))}")

    def content = new java.util.zip.ZipFile("$resource")
    content.entries().each{ entry ->
        def target = file("$dest/${entry.getName()}")
        if (entry.isDirectory()) {
            target.mkdirs();
        } else {
            target.getParent().mkdirs();
            file("$target").withOutputStream{ out -> out << content.getInputStream(entry)
            }
        }
    }
}
