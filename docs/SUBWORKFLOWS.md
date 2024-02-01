# Adding a new subworkflow to nf-scil

## Generate the template

First verify you are located at the root of this repository (not in `subworkflows`), then run the following interactive command :

```
nf-core subwworkflows create
```

That will ask you to give a name of your subworflow then the author name (github username).
Alternatively, you can use the following command to supply directly those informations :

```
nf-core subworkflows create name --author
```

## Generate the template

### Editing `./subworkflows/nf-scil/<name_of_your_workflow>/main.nf` :

We don’t have the choice to generate an empty template when we generate a subworflow, so the template is based on nf-core.

- remove the different comment lines.
- include your modules into your subworkflows.
  - remove the modules { SAMTOOLS_SORT} and { SAMTOOLS_INDEX } then includes yours with the good pathway:

```
include { <MODULES>	} from '../../../modules/nf-scil/<category/tool>/main'
```

[!NOTE]
You can also include workflows into your subworkflow :

```
include { <SUBWORKFLOWS> } from '../<subworkflows>/main'
```

- If you need to use functions from another library you can import them after the lines to include modules.
  gestimmo

```
import <library.function>
```

- Define your Workflow inputs.
  - A workflow can declare one or more input channels using the `take` keyword.
    Multiple inputs must be specified on separate lines:

```
take:
    <data1>
    <data2>
```

[!NOTE]
When the `take` keyword is used, the beginning of the workflow body must be defined with the `main` keyword !

- Fill the `main:` section.

  - define the channels of your different inputs.
    > You can check the possibilities given by nf-core to include your dataset in the nextflow documentation : https://www.nextflow.io/docs/latest/channel.html .
  - Compose your workflow with the different modules and workflow invoked above.
    > They also exist special operators to change the way content is composed : https://www.nextflow.io/docs/latest/workflow.html#special-operators .

- define your Workflow outputs.
  - A workflow can declare one or more output channels using the `emit` keyword.

```
emit:
    <modules>.out
```

> If an output channel is assigned to an identifier in the emit block, the identifier can be used to reference the channel from the calling workflow.

```
emit:
    my_data = <modules>.out
```

### Editing `./subworkflows/nf-scil/<name_of_your_workflow>/meta.yml` :

Fill the sections you find relevant. There is a lot of metadata in this file, but we
don't need to specify them all. At least define the `keywords`, describe the workflow'
`inputs` and `outputs`, and add a `short description` for the use of the subworkflow.

### Editing `./test/subworkflows/nf-scil/<name_of_your_workflow>/main.nf` :

### Editing `./test/subworkflows/nf-scil/<name_of_your_workflow>/nextflow.config` :

## Run the tests to generate the test metadata file

## Last safety test

## Submit your PR
