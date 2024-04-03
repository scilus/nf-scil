

process TESTDATA_SIZEOF {
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif':
        'scilus/scilus:1.6.0' }"

    output:
    path "versions.yml"                                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    python - << EOF

    import numpy as np

    from sys import byteorder
    print(f"endianness {byteorder}")

    def describe(_name, _datatype, _info_dt):
        _dt = np.dtype(_datatype)
        print(f"{_name} -> {_datatype} :")
        print(f"    -> {np.dtype(_datatype).name} : {_dt.itemsize} ({_dt.byteorder})")
        print(f"    -> alignment : {_dt.alignment}")
        print(f"       -> Info {_info_dt}")

    names = ["bool_", "byte", "ubyte", "short", "ushort", "intc"
             "uintc", "int_", "uint", "longlong", "ulonglong",
             "half", "float16", "single", "double", "longdouble",
             "csingle", "cdouble", "clongdouble"]
    dtypes = [np.bool_, np.byte, np.ubyte, np.short, np.ushort, np.intc,
              np.uintc, np.int_, np.uint, np.longlong, np.ulonglong,
              np.half, np.float16, np.single, np.double, np.longdouble,
              np.csingle, np.cdouble, np.clongdouble]
    checks = [np.iinfo, np.iinfo, np.iinfo, np.iinfo, np.iinfo, np.iinfo,
              np.iinfo, np.iinfo, np.iinfo, np.iinfo, np.iinfo,
              np.finfo, np.finfo, np.finfo, np.finfo, np.finfo,
              np.finfo, np.finfo, np.finfo]

    for n, dt, c in zip(names, dtypes, checks):
        try:
            describe(n, dt, c(dt))
        except BaseException as e:
            print(f"{e}")

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
