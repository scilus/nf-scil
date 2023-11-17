#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

import java.nio.file.Files

include { TESTDATA_SCILPY } from '../../../../../modules/nf-scil/testdata/scilpy/main.nf'

workflow test_preproc_normalize {

    test_data_path = Files.createTempDirectory("test.test-data.scilpy.bids-json")
    TESTDATA_SCILPY ( "bids_json.zip", test_data_path )

}
