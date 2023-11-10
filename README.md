# `nf-scil`

Welcome to `nf-scil` ! A **Nextflow** modules and workflows repository for neuroimaging 
maintained by the [SCIL team](https://scil-documentation.readthedocs.io/en/latest/). The 
primary focus of the library is to provide pre-built processes and processing sequences for 
**diffusion Magnetic Resonance Imaging**, optimized for *Nextflow DLS2*, based on open-source 
technologies and made easily available to pipeline's developers through the `nf-core` 
framework.

# Using modules from `nf-scil`

To import modules from `nf-scil`, you first need to install [nf-core](https://github.com/nf-core/tools) 
on your system (can be done simply using `pip install nf-core`). Once done, `nf-scil` 
modules are imported using this command :

```bash
nf-core modules \
  --git-remote https://github.com/scilus/nf-scil.git \
  install <category>/<tool>
```

where you input the `<tool>` you want to import from the desired `<category>`. To get 
a list of the available modules, run :

```bash
nf-core modules \
  --git-remote https://github.com/scilus/nf-scil.git \
  list remote
```

# Developing in `nf-scil`

## Dependencies

- Python &GreaterEqual; 3.8, < 3.13
- Nextflow &GreaterEqual; 21.04.3

## Developer installation

The project uses *poetry* to manage python dependencies. To install it using pipx, 
run the following commands :

```
pip install pipx
pipx ensurepath
pipx install poetry
```

> [!NOTE]
> If the second command above fails, `pipx` cannot be found in the path. Prepend the 
  second command with `$(which python) -m` and rerun the whole block.

Once done, install the project with : 

```
poetry install
```

## Loading the project's environment

The project scripts and dependencies can be accessed using :

```
poetry shell
```

which will activate the project's python environment in the current shell. To 
exit the environment, simply enter the `exit` command in the shell.

> [!IMPORTANT]
> Do not use traditional deactivation (calling `deactivate`), since it does not relinquish 
  the environment gracefully, making it so you won't be able to reactivate it without 
  exiting the shell.

## Contributing to `nf-scil`

If you want to propose a new `module` to the repository, follow the guidelines in the 
[module creation](./docs/MODULE.md) documentation. we follow standards closely 
aligned with `nf-core`, with some exceptions on process atomicity and how test data is 
handled. Modules that don't abide to them won't be accepted and PR containing them will 
be closed automatically.

## Running tests

Tests are run through `nf-core`, using the command :

```bash
nf-core modules \
  --git-remote https://github.com/scilus/nf-scil.git \
  test <category/tool>
```

The tool can be omitted to run tests for all modules in a category.
