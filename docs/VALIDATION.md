
# Code standards and formatting

Standards and formatting are aligned closely with `nf-core`, with minor simplifications. Refer to
the [nf-core documentation](https://nf-co.re/docs/contributing/modules) to get the full list of
guidelines and conventions

## Code linting

Before submitting to _nf-scil_, once you've commit and push everything, the code need to be correctly
linted, else the checks won't pass. This is done using `prettier` on your new module, through the _nf-core_
command line :

```bash
nf-core modules \
  --git-remote <your repository> \
  --branch <your branch unless main branch> \
  lint <category>/<tool>
```

You'll probably get a bunch of _whitespace_ and _indentation_ errors, but also image errors, bad _nextflow_
syntax and more. You need to fix all `errors` and as much as the `warnings`as possible.


# Testing infrastructure

## Developing test cases with nf-test

**In construction**

## Test data infrastructure

> [!IMPORTANT]
> Do not use the .test_data directory for your tests, use the Scilpy fetcher. If you need data to be uploaded,
> signal it to your reviewers when submitting your PR

### Using Scilpy Fetcher

The Scilpy Fetcher is a tool that allows you to download datasets from the Scilpy test data
depository. To use it, first include the _fetcher workflow_ in your test's `main.nf` :

```groovy
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'
```

The workflow has two inputs :

- A channel containing a list of archives names to download. Refer to [this page](./SCILPY_DATA.md) for a
  list of available archives and their content.

- A name for the temporary directory where the data will be put.

To call it, use the following syntax :

```groovy
archives = Channel.from( [ "<archive1>", "archive2", ... ] )
LOAD_TEST_DATA( archives, "<directory>" )
```

> [!IMPORTANT]
> This will download the `archives` and unpack them under the `directory`
> specified, using the archive's names as `sub-directories` to unpack to.

The archives contents are accessed using the output parameter of the workflow
`LOAD_TEST_DATA.out.test_data_directory`. To create the test input from it for
a given `PROCESS` to test use the `.map` operator :

```groovy
input = LOAD_TEST_DATA.out.test_data_directory
  .map{ test_data_directory -> [
    [ id:'test', single_end:false ], // meta map
    file("${test_data_directory}/<file for input 1>"),
    file("${test_data_directory}/<file for input 2>"),
    ...
  ] }
```

Then feed it to it :

```groovy
PROCESS( input )
```

> [!NOTE]
> The subworkflow must be called individually in each test workflow, even if they download
> the same archives, since there is no mechanism to pass data channels to them from the
> outside, or share cache between them.

### Using the `.test_data` directory

> [!WARNING]
> This section is kept for legacy only, until the tests relying on it are updated.

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

```groovy
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

```groovy
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
