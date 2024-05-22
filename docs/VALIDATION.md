
# Code standards and formatting

Standards and formatting are aligned closely with `nf-core`. Refer to the
[nf-core documentation](https://nf-co.re/docs/contributing/modules) to get the full
list of guidelines and conventions.

* [Code standards and formatting](#code-standards-and-formatting)
  * [Module standards](#module-standards)
    * [Standards applying to the `process`](#standards-applying-to-the-process)
    * [Standards applying to `meta.yml` files](#standards-applying-to-metayml-files)
  * [Code linting](#code-linting)
  * [Prettier installation](#prettier-installation)
* [Testing infrastructure](#testing-infrastructure)
  * [Running tests](#running-tests)
  * [Developing test cases with nf-test](#developing-test-cases-with-nf-test)
  * [Test data infrastructure](#test-data-infrastructure)
    * [Using Scilpy Fetcher](#using-scilpy-fetcher)
    * [Using the `.test_data` directory](#using-the-test_data-directory)

## Standards applying to the `process` (in `<MODULE>/main.nf`)

### name

the name is CAPITALIZED, and is composed of the category the module belongs to, followed its tool name, separated by an underscore. e.g. : `DENOISING_NLMEANS`.

### label

the resources for the module are assigned dynamically, using different classes
defined by `process resource labels`. It is required to define one (you can define
many), so the resources assigned are tailored correctly to the module's need :

- process_single : single core with increasing memory
- process_low, process_medium, process_high : increasing core count and memory size
- process_long : increased process wall-time before timeout
- process_high_memory : increased memory size

Values will assigned to those `labels` by various configuration profiles, such as
the ones of a pipeline, through it's `nextflow.config` file.

### output

List **all** possible outputs of the module, someone might need them ! Make them
optional if required.

### stub

The rule of thumb for the stub is simple : create `all` possible outputs of the
module. A simple way in bash is to use `touch` to create empty files for each of
them. Also create a `version.yml` file, containing the version of the commands and
libraries used by the module.

### version.yml

The version file is a simple YAML file containing the version of the commands and
libraries used by the module. Use `cat` to add them all in a single file, at the end
of the `script` :

```bash
cat << EOF > version.yml
    <command> : $(<command to get the version>),
    <command> : <hardcoded version>
    ...
EOF
```

## Standards applying to `meta.yml` files

Those files are the backbone of `nf-scil` command line interfaces. When a user wants
to `list` available modules and subworkflows, he'll also get basic infos on them.
When he further investigate a module or subworkflow to get `info`, he'll get the
full description, with a list of the awaited inputs and expected outputs of the
module, all ready for him to use.

The types allowed for the `inputs` and `outputs` are : `map`, `list`, `file`, `directory`, `string`,
`integer`, `float` and `boolean`.

### description

Give a good, but concise description of what the `module` or `subworkflow` does. If there
are multiple use-case, or that specifying some inputs changes some behaviors, mention it
clearly here. For `subworkflows`, give a thorough listing of the steps included and describe
them briefly, referring to the `modules` and `subworkflows` used to perform them.

### inputs and outputs

List all inputs and outputs of the module, in the same order as they are supplied
or produced by the module. For each, give a short description, specify if it is
optional or not. Be sure to mention all kinds an input can be, if there is multiple
even so.

## Code linting

Code linting is done by [prettier](https://prettier.io/). It is available through `Node.js`, refer to
[this section](#prettier-installation) for installation instructions. Linting a `module` or
subworkflow is done through the _nf-core_ command line :

```bash
nf-core <modules|subworkflows> \
  --git-remote <your repository> \
  --branch <your branch unless main branch> \
  lint <category/tool|subworkflow>
```

The command outputs a list of  `warnings` and `errors`, that should all be fixed, if possible. Other
files in the repository can require linting, but cannot be processed using `nf-core`. In this case,
use the `prettier` command line tool :

```bash
prettier --write <file>
```

## Prettier installation

To install **Prettier** for the project, you need to have `node` and `npm` installed on
your system to at least version 14. On Ubuntu, you can do it using snap :

```bash
sudo snap install node --classic
```

However, if you cannot install snap, or have another OS, refer to the
[official documentation](https://nodejs.org/en/download/package-manager/) for the installation procedure.

Under the current configuration for the _Development Container_, for this project, we use
the following procedure, considering `${NODE_MAJOR}` is at least 14 for Prettier :

```bash
curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - &&\
apt-get install -y nodejs

npm install --save-dev --save-exact prettier

echo "function prettier() { npm exec prettier $@; }" >> ~/.bashrc
```

# Testing infrastructure

## Running tests

All tests are run using the `nf-core` commands for either `modules` or `subworkflows` :

```bash
nf-core <modules|subworkflows> \
  --git-remote <remote-url> \
  test <category/tool|subworkflow>
```

When running tests for `modules`, the `tool` can be omitted to run tests for all modules in a category. Test
cases are located under the `tests` directory for legacy tests using `pytest-workflow`. For new tests, using the
`nf-test` framework instead, they are located aside the `module` or `subworkflow` code, in the same directory as
it's `main.nf`.

## Developing test cases with nf-test

**In construction**

## Fetching data for tests

The Scilpy Fetcher is a tool that allows you to download datasets from the Scilpy test data
repository. Follow [this link](./TEST_DATA.md) for a global view of available test archives and links to download them. To use it, first include the _fetcher workflow_ in your test's `main.nf` :

```groovy
include { LOAD_TEST_DATA } from '../../../../../subworkflows/nf-scil/load_test_data/main'
```

The workflow has two inputs :

- A channel containing a list of archives names to download; names are available [here](./TEST_DATA.md).

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
