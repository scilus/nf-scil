# nf-scil
SCIL Nextflow Toolbox

# Installation

On a fresh download of the repository, the *git* structure must be updated to 
include the *nf-scil-modules* submodule in the directory tree. To do so, run :

```
git submodules init
```

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

# Creating a new module

To create a new module, run : 

```
nf-core modules create \
    ---dir nf-scil-modules/ \
    --meta \
    --empty-template
```

This will create the module template in the *nf-scil-modules* sub-repository, 
with the informations entered in the shell.