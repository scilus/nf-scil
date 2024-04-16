# Adding a new module to nf-scil

* [Adding a new module to nf-scil](#adding-a-new-module-to-nf-scil)
  * [Generate the template](#generate-the-template)
    * [Edit `./modules/nf-scil/<category>/<tool>/main.nf`](#edit-modulesnf-scilcategorytoolmainnf)
    * [Edit `./modules/nf-scil/<category>/<tool>/meta.yml`](#edit-modulesnf-scilcategorytoolmetayml)
  * [Generate the tests](#generate-the-tests)
    * [Edit `./tests/modules/nf-scil/<category>/<tool>/main.nf`](#edit-testsmodulesnf-scilcategorytoolmainnf)
    * [Edit `./tests/modules/nf-scil/<category>/<tool>/nextflow.config`](#edit-testsmodulesnf-scilcategorytoolnextflowconfig)
    * [Create the validation file](#create-the-validation-file)
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

- Add your input channels in the `input:` section :

  > Each line below `input:` defines an input channel for the process. A channel can
  > receive one (`val`, `path`, ...) or more (`tuple`) values per item.

  > When possible, add all optional input parameters (not data !) to `task.ext` instead of
  > listing them in the `input:` section (see [this section](#defining-processes-optional-parameters)
  > for more information).

  - All input channels are assumed to be `required` by default.

  - To bind a channel to a specific id (e.g. a subject), use a `tuple` and the
    `meta`map :

    ```groovy
    tuple val(meta), path(f1), path(f2), ...
    ```

  - A `path` CAN be optional (though it is not officially supported). If it is
    supplied an empty list `[]` latter on, then it's value will evaluate to `false`
    in the process' `script`. This mechanism can be used to disable some processing
    steps.

    > If you decide an input `path` value is optional, add `/* optional, value = [] */`
    > aside the parameter (e.g. f1 is optional, so `path(f1) /* optional, value = [] */`
    > or even `tuple val(meta), path(f1) /* optional, value = [] */, path(...` are valid
    > syntaxes). This will make input lines long, but they will be detectable. When we
    > can define input tuples on multiple lines, we'll deal with this.

  - If the value must be prepared before being used in the script, use `groovy` code,
    before the script definition (in `""" """`) to do so. For example, if an optional
    input must be delt with beforehand, use :

    ```groovy
    def optional_input1 = input1 ? "<unpack input1>" : "<default value>"
    ```

    Then, use the variable `optional_input1` in the script.

- Add all outputs in the `output` section :

  - As for inputs, each line defines an output channel. Binding a channel to a
    specific id (e.g. a subject) is done the same way.

  - File extensions MUST ALWAYS be defined (e.g. `path("*.{nii,nii.gz}")`).

  > Each line MUST use `emit: <name>` to make its results available inside Nextflow using
  > a relevant `name`. Results are accessible using : `PROCESS_NAME.out.<name>`.

  > Optional outputs ARE possible, add `, optional: true` after the `emit: <name>` clause.

- Fill the `script` section :

  - If an output is bound to a specific id (e.g. a subject), use the `prefix`
    variable when naming it (e.g. `${prefix}_name.ext`). If needed, modify the
    `prefix` variable definition in the groovy pre-script.

  - Define dependencies versions :

    In the versioning section at the bottom of the script :

    ```bash
    cat <<-END_VERSIONS > versions.yml
      "${task.process}":
        <your dependencies>
    END_VERSIONS
    ```

    replace the content already present with the versions of your tools. Refer to
    [this section](./VALIDATION.md#versionyml) for more information.

- Fill the `stub` section, following the [guidelines](./VALIDATION.md#stub).

### Edit `./modules/nf-scil/<category>/<tool>/meta.yml`

Fill the sections following the [guidelines](./VALIDATION.md#standards-applying-to-metayml-files).
In addition, describe the `tools` used by the module and define `keywords` to
facilitate its search with `nf-core` commands.

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

In construction

## Lint your code

Run `prettier` on your new module, through the _nf-core_ command line :

```bash
nf-core modules \
  --git-remote <your repository> \
  --branch <your branch unless main branch> \
  lint <category>/<tool>
```

and fix all `errors` and as much as the `warnings`as possible. Refer to
[this section](./VALIDATION.md#code-standards-and-formatting) for further information.

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
