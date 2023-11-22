## Describe your changes

## Say which test data are used by your module

## Checklist before requesting a review

- Create the tool:
  - [ ] Edit `./modules/nf-scil/<category>/<tool>/main.nf`
  - [ ] Edit  `./modules/nf-scil/<category>/<tool>/meta.yml`
- Generate the tests:
  - [ ] Edit `./tests/modules/nf-scil/<category>/<tool>/main.nf`
  - [ ] Edit `./tests/modules/nf-scil/<category>/<tool>/nextflow.config`
  - [ ] Add test data locally for tests with the fork repository
  - [ ] Generate the test infrastructure and *md5sum* for all outputs
  - [ ] Test the module in a **REAL** DSL2 pipeline or a *dummy* one
- Ensure the syntax is correct :
  - [ ] Check indentation abides with the rest of the library (don't hesitate to correct others !)
  - [ ] Lint everything. Ensure your variables have good names.
