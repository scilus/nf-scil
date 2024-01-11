# Adding a new module to nf-scil

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
    <category/tool>
```

You will still have to interact with the **bioconda** prompt, still select `no`.

> [!NOTE]
> Once used to the conventions, adding `--empty-template` to the command will disable
> auto-generation of comments, examples and TODOs and can be a time-saver.

## Edit the template

The template has to be edited in order to work with `nf-scil` and still be importable
through `nf-core`. Refer to the `betcrop/fslbetcrop` module for an example as it should
already follow all guidelines. You will find related files in :

- `modules/nf-scil/betcrop/fslbetcrop`
- `tests/modules/nf-scil/betcrop/fslbetcrop`

### Editing `./modules/nf-scil/<category>/<tool>/main.nf` :

- Remove the line `conda "YOUR-TOOL-HERE"`.

- If the process uses the `scilus` container, use the following replacements,
  else remove the whole section.

  `depot.galaxyproject.org...` &DoubleLongRightArrow; `https://scil.usherbrooke.ca/containers/scilus_1.6.0.sif`

  `biocontainers/YOUR-TOOL-HERE` &DoubleLongRightArrow; `scilus/scilus:1.6.0`

- Add your inputs in the `input:` section :

  > Each line below `input:` defines an input channel for the process. A channel can
  > receive one (`val`, `path`, ...) or more (`tuple`) values per item.

  > When possible, add all optional input parameters (not data !) to `task.ext` instead of
  > listing them in the `input:` section (see [this section](#defining-processes-optional-parameters)
  > for more information).

  - All inputs are assumed to be `required` by default.

  - If an input is scoped to a subject, the line MUST start with `tuple val(meta), `.

  - An input `path` CAN be optional (though it is not officially supported). You simply
    have to pass it an empty list `[]` for Nextflow to consider its value empty, but
    correct.

    > If you decide an input `path` value is optional, add `/* optional, value = [] */`
    > aside the parameter (e.g. f1 is optional, so `path(f1) /* optional, value = [] */`
    > or even `tuple val(meta), path(f1) /* optional, value = [] */, path(...` are valid
    > syntaxes). This will make input lines long, but they will be detectable. When we
    > can define input tuples on multiple lines, we'll deal with this.

    In the script section, before the script definition (in `""" """`), unpack the
    optional argument into a `usable variable`. For a optional input `input1`, add :

        def optional_input1 = input1 ? "<unpack input1>" : "<default if input1 unusable>"

    The variable `optional_input1` is the one to use in the script.

    > At its most simple, a variable is `usable` if its conversion to a string is valid
    > in the script (e.g. : if a variable can be empty or null, then its conversion to an
    > empty string must be valid in the sense of the script for the variable to be considered
    > `usable`).

- Add all outputs in the `output` section :

  - As for inputs, each line defines an output channel. If an output is scoped to a
    subject, the line MUST start with `tuple val(meta), `.

  - File extensions MUST ALWAYS be defined (e.g. `path("*.{nii,nii.gz}")`).

  > Each line MUST use `emit: <name>` to make its results available inside Nextflow using
  > a relevant `name`. Results are accessible using : `PROCESS_NAME.out.<name>`.

  > Optional outputs ARE possible, add `, optional: true` after the `emit: <name>` clause.

- Fill the `script` section :

  - Use the `prefix` variable to name the scoped output files. If needed, modify the
    variable definition in the groovy pre-script.

  - Define dependencies versions :

    In the versioning section at the bottom of the script :

    ```bash
    cat <<-END_VERSIONS > versions.yml
      "${task.process}":
        <your dependencies>
    END_VERSIONS
    ```

    remove the lines in between the `cat` and the `END_VERSIONS` line. In it, add
    for each dependency a new line in the format : `<name>: <version>`.

    > You can hard-bake the version as a number here, but if possible extract if from
    > the dependency dynamically. Refer to the `betcrop/fslbetcrop` module, in `main.nf`
    > for examples on how to extract the version number correctly.

- Fill the `stub` section :

  Using the same conventions as for the `script` section, define a simple test stub :

  - Call the helps of all scripts used, if possible.

  - Call `touch <file>` to generate empty files for all required outputs.

### Editing `./modules/nf-scil/<category>/<tool>/meta.yml` :

Fill the sections you find relevant. There is a lot of metadata in this file, but we
don't need to specify them all. At least define the `keywords`, describe the process'
`inputs` and `outputs`, and add a `short documentation` for the tool(s) used in the process.

> [!IMPORTANT]
> The `tool` documentation does not describe your module, but to the tools you use in
> the module ! If you use scripts from `scilpy`, here you describe scilpy. If using
> `ANTs`, describe ANts. Etcetera.

### Editing `./tests/modules/nf-scil/<category>/<tool>/main.nf` :

The module's test suite is a collection of workflows containing isolated test cases. You
can add as many more tests as your heart desire (not too much), in addition to the one
provided.

> [!IMPORTANT]
> Each workflow is atomic, in which it does not contain more than a single test to run.

In any case, to get the test workflows working, do the following :

- Either modify the auto-generated `input` object to add your test data or replace it with
  a _fetcher workflow_. You can do this at the end, when you have defined your test cases.
  Refer to [this section](#test-data-infrastructure) to see which use case fits your tests
  better.

### Editing `./tests/modules/nf-scil/<category>/<tool>/nextflow.config` :

You don't need to touch anything here, except if you have defined optional parameters
with `task.ext` and want to alter their values for some test cases. Refer to
[this section](#defining-processes-optional-parameters) to see how to scope those parameters
to specific tests using `selectors`.

## Run the tests to generate the test metadata file

> [!WARNING]
> Verify you are located at the root of `nf-scil` (not inside modules) before
> running commands !

Once the test data has been pushed to the desired location and been made available to the
test infrastructure using the relevant configurations, the test module has to be pre-tested
so output files that gets generated are checksum correctly.

> [!IMPORTANT]
> The test infrastructure uses `pytest-workflow` to run the tests. It is `git-aware`,
> meaning that only files either `committed` or `staged` will be considered by
> the tests. To verify that your file will be loaded correctly, check that it is
> listed by `git ls-files`.

Run :

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

> [!NOTE]
> To be valid, your `DSL2` Nextflow pipeline must have a `modules/` directory, as well as a
> `writable` or non-existent `.modules.yml` file.

> [!NOTE]
> A `dummy` pipeline is simply a directory containing an empty `modules/` directory and a
> `main.nf` file with the following content : `workflow {}`.

Run the following command, to try installing the module :

```
nf-core module \
  --git-remote https://github.com/scilus/nf-scil.git \
  --branch <branch> \
  install <category>/<tool>
```

You'll get a message at the command line, indicating which `include` line to add to your
pipeline to use your module. If you do it, add the module to your pipeline, run it and
validate it's working, and you're done !

> [!NOTE]
> If working with the `dummy`, don't bother running it, we say it's working, so you can
> delete the test and submit the PR !

## Submit your PR

Open a PR to the `nf-scil` repository master. We'll test everything, make sure it's
working and that code follows standards.

> [!NOTE]
> It's the perfect place to get new tools added to our containers, if need be !

Once LGTM has been declared, wave to the maintainers and look at your hard work paying off.

PR merged !

# Defining processes optional parameters

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
it is possible to affect the processes inside a specific workflow as well :

```groovy
process {
  withName: "WORKFLOW_X*" {
    task.ext.param1 = "<scoped to processes in WORKFLOW_X value>"
  }
}
```

> [!IMPORTANT]
> Modules inherit **selectors**. Thus, a module renamed at import (`import {A as B}`)
> will be affected both by the selection `withName: "A"` and `withName: "B"`. However,
> parameters defined by `B` will have precedence on those define in `A`.

> [!IMPORTANT]
> The same stands for **selectors** defined on multiple levels, implicit (`withName: WORKFLOW_X*`)
> or explicit (`withName: WORKFLOW_Y:B`).

# Test data infrastructure

> [!WARNING]
> WORK IN PROGRESS, WILL CHANGE SOON-ISH. 2 temporary ways are available now and will be
> deprecated when the **DVC** infrastructure is ready.

## Using the `.test_data` directory

Some test datasets are available under the `.test_data` directory. You can use them as you wish,
but inspect them before you do, since some dataset have been lean down and could not fit the
reality of your test cases. **Do not add or modify data in this directory**. Tests packages are
separated into `heavy` and `light` categories depending on their filesize. Inside, they are divided
into relevant sub-categories (dwi, anat, ...).

To bind data to test cases using this infrastructure, it first has to be added to `tests/config/test_data.config`
in order to be visible. The configuration is a nesting of dictionaries, all test data
files must be added to the `params.test_data` of this structure, using this convention
for the `dictionary key` : `params.test_data[<category>][<tool>][<input_name>]`.

Thus, a new binding in `tests/config/test_data.config` should resemble the following

```
params {
    test_data {
        ...

        "<category>": {
            ...

            "<tool>": {
                ...

                "<input_name1>": "${params.test_data_base}/<light or heavy>/.../<file1>"
                "<input_name2>": "${params.test_data_base}/<light or heavy>/.../<file2>"

                ...
            }

        ...
        }
    }
}
```

You then use `params.test_data[<category>][<tool>][<input_name>]` in your test cases to
attach the data to the test case, since the `params.test_data` collection is loaded
automatically. To do so, in a test workflow, define an `input` object :

```
input = [
  [ id:'test', single_end:false ], // meta map
  params.test_data[<category>][<tool>][<input_name1>],
  params.test_data[<category>][<tool>][<input_name2>],
  ...
]
```

and use it as input to the processes to test.

> [!IMPORTANT]
> Keep the `meta map` in the first entry, modify it as necessary

## Using Scilpy Fetcher

The Scilpy Fetcher is a tool that allows you to download datasets from the Scilpy test data
depository. To use it, first include the _fetcher workflow_ in your test's `main.nf` :

```
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'
```

The workflow has two inputs :

- A channel containing a list of archives names to download. Refer to [this page](./SCILPY_DATA.md) for a
  list of available archives and their content.

- A name for the temporary directory where the data will be put.

The directories where the archives contents are unpacked are accessed using the output
parameter of the workflow `LOAD_TEST_DATA.out.test_data_directory`. To create the test
input from it, use the `.map` operator :

```
input = LOAD_TEST_DATA.out.test_data_directory
  .map{ test_data_directory -> [
    [ id:'test', single_end:false ], // meta map
    file("${test_data_directory}/<file for input 1>"),
    file("${test_data_directory}/<file for input 2>"),
    ...
  ] }
```

> [!NOTE]
> The subworkflow must be called individually in each test workflow, even if they download
> the same archives, since there is no mechanism to pass data channels to them from the
> outside.
