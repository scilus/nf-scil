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

If the second command above fails, `pipx` cannot be found in the path. Prepend the 
second command with `$(which python) -m` and rerun the whole block.

Once done, install the project with : 

```
poetry install
```

# Load the project's environment

The project scripts and dependencies can be accessed using :

```
poetry shell
```

which will activate the project's python environment in the current shell. To 
exit the environment, simply enter the `exit` command in the shell. Take note not to 
use traditional deactivation (calling `deactivate`), since it does not relinquish the 
environment gracefully, making it so you won't be able to reactivate it without exiting
the shell.

# Adding a new module to nf-scil

Module creation for `nf-scil` aligns closely with `nf-core`, up to minor changes 
(mostly conventions we are not enforcing).

## Generate the template

First verify you are located at the root of this repository (not in `modules`), then run the following interactive command :

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

Note that once used to the conventions, adding `--empty-template` to the command
will disable auto-generation of comments, examples and TODOs and can be a time-saver.

## Edit the template

The template has to be edited in order to work with `nf-scil` and still be importable 
through `nf-core`. Refer to the `betcrop/cropvolume` module for an example as it should 
already follow all guidelines. You will find related files in :

- `modules/nf-scil/betcrop/cropvolume`
- `tests/modules/nf-scil/betcrop/cropvolume`

Editions are to be done in two locations :

- `./modules/nf-scil/<category>/<tool>`
  - `main.nf` :
    - remove the line `conda "YOUR-TOOL-HERE"`.
    - if the process uses the `scilus` container, use the following replacements, 
      else remove the whole section.
      - `depot.galaxyproject.org...` => `scil.usherbrooke.ca/containers/scilus_1.6.0.sif`
      - `biocontainers/YOUR-TOOL-HERE` => `scilus/scilus:1.6.0`
    - add your inputs in the `input` section.
      - each line below `input:` defines an input channel for the process.
        - A channel can receive one (`val`, `path`, ...) or more (`tuple`) values per item.
      - all inputs are assumed to be `required` by default.
      - if an input is scoped to a subject, the line MUST start with `tuple val(meta), `.
      - an input `path` CAN be optional (though it is not officially supported). You simply 
        have to pass it an empty list `[]` for Nextflow to consider its value empty, but 
        correct.
        - If you decide an input `path` value is optional, add `/* optional, value = [] */` 
          aside the parameter (e.g. f1 is optional, so `path(f1) /* optional, value = [] */` or even 
          `tuple val(meta), path(f1) /* optional, value = [] */, path(...` are valid syntaxes). This will 
          make input lines long (I know), but they will be detectable and when we can define 
          input tuples on multiple lines, we'll deal with this.
        - In the script section, before the script definition (in `""" """`), unpack the optional 
          argument into a `usable variable`.
          - For a optional input `input1`, add :
            
            `def optional_input1 = input1 ? "<unpack input1>" : "<default if input1 unusable>"`

            The variable `optional_input1` is the one to use in the script.
          - At its most simple, a variable is `usable` if its
            conversion to a string is valid in the script (e.g. : if a variable can be empty or 
            null, then its conversion to an empty string must be valid in the sense of the script 
            for the variable to be considered `usable`).
        - when possible, add all optional input parameters (not data !) to `task.ext` instead of 
          listing them in the `inputs` section (see below for more information).
    - add all outputs in the `output` section.
      - as for inputs, each line defines an output channel
      - if an output is scoped to a subject, the line MUST start with `tuple val(meta), `.
      - each line MUST use `emit: <name>` to make its results available inside Nextflow using a relevant `name`.
        - results are accessible using : `PROCESS_NAME.out.<name>`
      - optional outputs ARE possible, add `, optional: true` after the `emit: <name>` clause.
      - file extensions MUST ALWAYS be defined (e.g. `path("*.{nii,nii.gz}")`).
    - In the `script` section :
      - use the `prefix` variable to name the scoped output files. If needed, modify the variable
        definition in the groovy pre-script.
      - use `$task.cpus` to define multithreading (if applicable). WE'LL DEAL WITH THIS ONCE WITH GROW OUT OF THE LABEL `process_single`.
      - define dependencies versions :
        - Modify the versioning section :
          ```bash
          cat <<-END_VERSIONS > versions.yml
            "${task.process}":
              <your dependencies>
          END_VERSIONS
          ```
          remove the lines in between the `cat` and the `END_VERSIONS` line. In it, add
          for each dependency a new line in the format : `<name>: <version>`. You can 
          hard-bake the version as a number here, but if possible extract if from the 
          dependency. Refer to the `betcrop/fslbetcrop` module, in `main.nf` for 
          examples on how to extract the version number correctly.
    - In the `stub` section :
      - Use the same conventions as for the `script` section.
      - Define a simple test stub.
        - Call the helps of all scripts used, if possible.
        - Call `touch <file>` to generate empty files for all required outputs.
  - `meta.yml` :
    - Fill the sections you find relevant. There is a lot of metadata in this 
      file, but we don't need to specify them all.
    - At least define the keywords, describe the process' inputs and outputs, and add 
      a short documentation for the tool(s) used in the process :
      - The `tool` documentation does not describe to your module, but to the tools 
        you use in the module ! If you use scripts from `scilpy`, here you describe 
        scilpy. If using `ANTs`, describe ANts. Etcetera.
- `./tests/modules/nf-scil/<category>/<tool>`
  - `main.nf` and `nextflow.config`
    - Add the test input data to the auto-generated `input` object. You can do this 
      at the end, when you have defined your test cases. Refer to the next section
      to see how to define your test data and, mostly, what keys to the nested
      `params.test_data` dictionary you need to use.
    - Modify the auto-generated `meta map` as necessary.
    - Add necessary configuration to `nextflow.config`
      - It is here you define the `task.ext` parameters values to use in the tests.
    - If you want, add as many more tests as your heart desire (not too much) !

## Define processes optional parameters

Using the DLS2 module framework, we can define passage of optional parameters using a configuration 
proprietary to the `process scope`, the `task.ext` mapping (or dictionary). In `nf-core`, the convention 
is to load `task.ext.args` with all optional parameters acceptable by the process.

This does not work perfectly for our use-cases, and instead, we use the whole `task.ext` as a 
parameters map. To define an optional parameter `param1` through `task.ext`, add the following to
the process script section, before the script definition (in `""" """`) :

```groovy

def args_for_cmd1 = task.ext.param1 ? "<parameter flag for param1 if needed> $task.ext.param1" 
                                    : '<empty string or what to do if not supplied>'
```

Then, use `args_for_cmd1` in the script. Defining the actual value for the parameters is done 
by means of `.config` files, inside the `process` scope. A global affectation of the parameter 
is as simple as :

```groovy 
process {
  task.ext.param1 = "<my global value>"
}
```

Doing so will affect **ALL** processes. To scope to a specific process, use the 
[process selectors](https://www.nextflow.io/docs/latest/config.html#process-selectors)
(`withName:` or `withLabel:`) :

```groovy
process {
  withName: "PROCESS1" {
    task.ext.param1 = "<scoped to PROCESS1 value>"
  }
}
```

You can define the selector on multiple levels and use glob matching, making it so that 
it is possible to affect a group of processes inside a specific workflow as well :

```groovy
process {
  withName: "WORKFLOW_X*" {
    task.ext.param1 = "<scoped to processes in WORKFLOW_X value>"
  }
}
```

Selection is `named based`, such that if the module is renamed at import (`import {A as B}`),
the selection `withName: "A"` won't apply. If the parameter must not change when the name 
changes, consider using `withLabel:` instead.

## Test data infrastructure

**WORK IN PROGRESS, WILL CHANGE SOON-ISH**

Test data is bound to this repository for now, all located under the `.test_data` 
directory. As such, every single dataset added MUST be as light as possible. Datasets 
must abide the following naming convention :

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

## Run the tests to generate the test metadata file

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

All the test case you defined will be run, watch out for errors ! Once everything runs 
smoothly, look at the test metadata file produced : `tests/modules/nf-scil/<category/<tool>/test.yml` 
and validate that ALL outputs produced by test cases have been caught. Their `md5sum` is 
critical to ensure future executions of your test produce valid outputs.

## Last safety test

You're mostly done ! If every tests passes, your module is ready ! Still, you have not tested 
that `nf-core` is able to find and install your module in an actual pipeline. First, to test 
this, your module must be pushed only to your repository, so ensure that. Next, you need to 
either locate yourself in an already existing `DSL2` Nextflow pipeline, or create a `dummy` 
testing one.

- Existing `DSL2` Nextflow pipeline :
  - To be valid, your pipeline must have a `modules/` directory, as well as a `writable` or 
    non-existent `.modules.yml` file.
- Create the `dummy` pipeline :
  - In an empty directory, create the `modules/` directory, and the `main.nf` file.
  - In the `main.nf` file, add an empty workflow : `workflow {}`

Run the following command, to try installing the module :

```
nf-core module \
  --git-remote https://github.com/scilus/nf-scil.git \
  --branch <branch> \
  install <category>/<tool>
```

You'll get a message at the command line, indicating which `include` line to add to 
your pipeline to use your module. If working with the `dummy`, don't bother running 
it, we say it's working, so you can delete the test and submit the PR ! However, if you 
can run the pipeline, do it and validate it's working, and you're done ! 

## Submit your PR

Open a PR to the `nf-scil` repository master. We'll test everything, make sure it's 
working and that code follows standards. It's the perfect place to get new tools added 
to our containers, if need be !

Once LGTM has been declared, you'll need to do a last step to update the `main` with your 
test data. Go in the `tests/config/test_data.config` file and change all references to 
your branch so it points to `main`. If you modified `params.test_data_base` or changed it 
for your test cases, don't forget to switch them to `params.test_data_base`, since once merged,
test data isn't bound to your fork anymore. Then wave to the maintainers and look at your hard 
work paying off. PR merged !
