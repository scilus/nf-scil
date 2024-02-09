#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

import java.nio.file.Files

include { TESTDATA_SCILPY } from '../../../../../modules/nf-scil/testdata/scilpy/main.nf'

workflow test_output_to_temp {

    test_data_path = Files.createTempDirectory("test.test-data.scilpy.bids-json")
    TESTDATA_SCILPY ( "bids_json.zip", test_data_path )

}

workflow test_output_to_work {

    TESTDATA_SCILPY ( "bids_json.zip", [] )

}
