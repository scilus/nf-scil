# nf-scil
SCIL Nextflow Toolbox

# Installation

The project uses *poetry* to install dependencies. To install it using pipx, 
run the following commands :

```
pip install pipx
pipx ensurepath
pipx install poetry
```

The project is then installed using : 

```
poetry install
```

# Load the project's environment

The project scripts and dependencies can be accessed using :

```
poetry shell
```

which will activate the project's python environment in the current shell. To 
exit the environment, simply enter the `exit` command in the shell.

# Adding a new module to nf-scil

Module creation for `nf-scil` aligns closely with `nf-core`, up to minor changes 
(mostly conventions we are not enforcing).

## Generating the template

First verify you are located in this repository, then run the following interactive command :

```
nf-core modules create
```

You will be prompted several times to configure the new module correctly. Refer
to the following to ensure configuration abides with `nf-scil` :

- **Name of tool/subtool** : `category/tool` of the module you plan creating (e.g. denoising/nlmeans).
- **Bioconda package** : select `no`.
- **Github author** : use your Github handle, or `@scilus` if you prefer not being identified through nf-scil.
- **Resource label** : select `process_single` for now, for any tool (multiprocessing and acceleration will be delt with later).
- **Meta map** : select `yes`.

Alternatively, you can use the following command to supply nearly all information :

```
nf-core modules create \
    --author @scilus \
    --label process_single \
    --meta \
    --empty-template \
    <category/tool>
```

You will still have to interact with the **bioconda** prompt, still select `no`.

Note that once used to the conventions, adding "--empty-template" to the command
will disable auto-generation of comments, examples and TODOs and can be a time-saver.

## Editing the template

The template has to be edited in two locations :

- `./modules/nf-scil/<category>/<tool>`
  - `main.nf` :
    - remove the line `conda "YOUR-TOOL-HERE"`.
    - if the process uses the `scilus` container, use the following replacements, 
      else remove the whole section.
      - `depot.galaxyproject.org...` => `scil.usherbrooke.ca/containers/scilus_1.5.0.sif`
      - `biocontainers/YOUR-TOOL-HERE` => `scilus/scilus:1.5.0`
    - add your required inputs in the `input` section.
      - if an input is scoped to a subject, the line MUST start with `tuple val(meta), `.
    - add all outputs in the `output` section.
      - if an output is scoped to a subject, the line MUST start with `tuple val(meta), ...`.
      - each line MUST be `emit` its results using a relevant name.
      - optional outputs ARE possible, add `, optional: true` after the `emit` clause.
      - file extensions MUST ALWAYS be defined (e.g. `path("*.{nii,nii.gz}")`).
    - In the `script` section :
      - use the `prefix` variable to name the scoped output files.
      - use `$task.cpus` to define multithreading (if applicable).
      - replace version fetching :
        - `\$(echo \$(samtools ...` => `\$(scil_get_version.py 2>&1)`
    - In the `stub` section :
      - Use the same conventions as for the `script` section.
      - Define a simple test stub.
        - Call the helps of all scripts used, if possible.
        - Call `touch <file>` to generate empty files for all required outputs.
  - `meta.yml` :
    - Fill the sections as you find relevant. There is a lot of metadata in this 
      file, but we don't need to specify them all.
    - At least define the keywords and a short documentation for the tool, inputs and outputs.
    - If not specifying the `tools` section, leave it as is.
- `./tests/modules/nf-scil/<category>/<tool>`
  - `main.nf`
    - Add the test input data to the auto-generated `input` object (Refer to the next section 
      on how to bind test data to the infrastructure).
    - Modify the auto-generated `meta map` as necessary.

## Test data infrastructure

**WORK IN PROGRESS, WILL CHANGE SOON-ISH**

Test data is bound to this repository for now, all located under the `.test_data` 
directory. Datasets must abide the following naming convention :

- A test package for a `<category>` is located under `.test_data/<category>`.
- A test data file for a tool is named `<tool>_<input_name>.<ext>`, placed in that category directory.
  - e.g. : A tool `nlmeans` with input `image` and `mask` has 2 data points, named
    `nlmeans_image.nii.gz` and `nlmeans_mask.nii.gz` respectively.

Once added to the repository, the data has to be added to `tests/config/test_data.config` in
order to be visible. The configuration is a nesting of dictionaries, all test data 
files must be added to the `params.test_data` of this structure, using this convention 
for the `dictionary key` : 

- For the `dictionary key` : `params.test_data[<category>][<tool>][<input_name>]`
- For the file name
  - All files are indexed from the raw git repository. To scope correctly on branches 
    and through PR, the file name has to contain the `branch` name containing the file.
    Use this naming convention : `<branch>/.test_data/<category>/<tool>_<input_name>.<ext>`

Thus, a new dataset in `tests/config/test_data.config` should resemble the following

```
params {
    test_data {
        ...

        "<category>": {
            ...

            "<tool>": {
                ...

                "<input_name1>": "${params.test_data_base}/<branch>/.test_data/<category>/<tool>_<input_name1>.<ext>"
                "<input_name2>": "${params.test_data_base}/<branch>/.test_data/<category>/<tool>_<input_name2>.<ext>"

                ...
            }

        ...
        }
    }
}
```

## Running the tests to generate the test metadata file

Once the test data has been pushed to the desired location and been made available to the 
test infrastructure using the relevant configurations, the test module has to be pre-tested 
so output files that gets generated are checksum correctly. First, verify you are located 
at the root of `nf-scil` (not inside modules !), then run :

```
nf-core modules create-test-yml \
    --run-tests \
    --force \
    --no-prompts \
    <category/tool>
```