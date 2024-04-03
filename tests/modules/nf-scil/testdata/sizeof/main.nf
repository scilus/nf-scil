#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

import java.nio.file.Files

include { TESTDATA_SIZEOF } from '../../../../../modules/nf-scil/testdata/sizeof/main.nf'

workflow test_get_sizeof_datatypes {

    TESTDATA_SIZEOF (  )

}
