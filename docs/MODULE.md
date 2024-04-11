# Adding a new module to nf-scil

* [Adding a new module to nf-scil](#adding-a-new-module-to-nf-scil)
  * [Generate the template](#generate-the-template)
    * [Edit `./modules/nf-scil/<category>/<tool>/main.nf`](#edit-modulesnf-scilcategorytoolmainnf)
    * [Edit `./modules/nf-scil/<category>/<tool>/meta.yml`](#edit-modulesnf-scilcategorytoolmetayml)
  * [Generate tests for the module](#generate-tests-for-the-module)
    * [Edit `./tests/modules/nf-scil/<category>/<tool>/main.nf`](#edit-testsmodulesnf-scilcategorytoolmainnf)
    * [Edit `./tests/modules/nf-scil/<category>/<tool>/nextflow.config`](#edit-testsmodulesnf-scilcategorytoolnextflowconfig)
    * [Generate the test validation file](#generate-the-test-validation-file)
  * [Lint your code](#lint-your-code)
  * [Submit your PR](#submit-your-pr)
* [Defining processes optional parameters](#defining-processes-optional-parameters)

## Generate the template

First verify you are located at the root of this repository (not in `modules`), then run the following interactive command :

```bash
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

```bash
nf-core modules create \
    --author @scilus \
    --label process_single \
    --meta \
    <category>/<tool>
```

You will still have to interact with the **bioconda** prompt, still select `no`.

> [!NOTE]
> Once used to the conventions, adding `--empty-template` to the command will disable
> auto-generation of comments, examples and TODOs and can be a time-saver.

The template has to be edited in order to work with `nf-scil` and still be importable
through `nf-core`. Refer to the `betcrop/fslbetcrop` module for an example as it should
already follow all guidelines. You will find related files in :

- `modules/nf-scil/betcrop/fslbetcrop`

### Edit `./modules/nf-scil/<category>/<tool>/main.nf`

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

    ```groovy
    def optional_input1 = input1 ? "<unpack input1>" : "<default if input1 unusable>"
    ```

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

### Edit `./modules/nf-scil/<category>/<tool>/meta.yml`

Fill the sections you find relevant. There is a lot of metadata in this file, but we
don't need to specify them all. At least define the `keywords`, describe the process'
`inputs` and `outputs`, and add a `short documentation` for the tool(s) used in the process.
The types allowed for the `inputs` and `outputs` are : `map`, `list`, `file`, `directory`, `string`,
`integer`, `float` and `boolean`.

> [!IMPORTANT]
> The `tool` documentation does not describe your module, but to the tools you use in
> the module ! If you use scripts from `scilpy`, here you describe scilpy. If using
> `ANTs`, describe ANts. Etcetera.

Once done, commit your module and push the changes. Then, to look at the documentation it creates for your module, run :

```bash
nf-core modules \
  --git-remote <your reository> \
  --branch <your branch unless main branch> \
  info <category/name>
```

## Generate the tests

### Edit `./tests/modules/nf-scil/<category>/<tool>/main.nf`

The module's test suite is a collection of workflows containing isolated test cases. You
can add as many more tests as your heart desire (not too much), in addition to the one
provided.

> [!IMPORTANT]
> Each workflow is atomic, in which it does not contain more than a single test to run.

In any case, to get the test workflows working, do the following :

- Either modify the auto-generated `input` object to add your test data or replace it with
  a _fetcher workflow_. You can do this at the end, when you have defined your test cases.
  Refer to [this section](VALIDATION.md#test-data-infrastructure) to see which use case fits your tests
  better.

### Edit `./tests/modules/nf-scil/<category>/<tool>/nextflow.config`

You don't need to touch anything here, except if you have defined optional parameters
with `task.ext` and want to alter their values for some test cases. Refer to
[this section](#defining-processes-optional-parameters) to see how to scope those parameters
to specific tests using `selectors`.

### Create the validation file

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

```bash
nf-core modules create-test-yml \
    --run-tests \
    --force \
    --no-prompts \
    <category>/<tool>
```

All the test case you defined will be run, watch out for errors ! Once everything runs
smoothly, look at the test metadata file produced : `tests/modules/nf-scil/<category/<tool>/test.yml`
and validate that ALL outputs produced by test cases have been caught. Their `md5sum` is
critical to ensure future executions of your test produce valid outputs.

## Lint your code

Run `prettier` on your new module, through the _nf-core_ command line :

```bash
nf-core modules \
  --git-remote <your repository> \
  --branch <your branch unless main branch> \
  lint <category>/<tool>
```

and fix all `errors` and as much as the `warnings`as possible. Refer to
[this section](VALIDATION.md#code-standards-and-formatting) for further information.

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
