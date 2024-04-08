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
  - remove the modules `{ SAMTOOLS_SORT}` and `{ SAMTOOLS_INDEX }` then includes yours with the good pathway:

```
include { <MODULES>	} from '../../../modules/nf-scil/<category/tool>/main'
```

> [!NOTE]
> You can also include workflows into your subworkflow :

```
include { <SUBWORKFLOWS> } from '../<subworkflows>/main'
```

- If you need to use functions from another library you can import them after the lines to include modules.

```
import <library.function>
```

#### Define your Workflow inputs.

A workflow can declare one or more input channels using the `take` keyword.
Multiple inputs must be specified on separate lines:

```
take:
    channel_data1  // channel: [ val(meta), [ data1 ] ]
    channel_data2  // channel: [ val(meta), [ data2 ] ]
```

> [!NOTE]
> When the `take` keyword is used, the beginning of the workflow body must be defined with the `main` keyword !

#### Fill the `main:` section.

Compose your workflow using the different modules and workflows you've included above.
Modules using input channels just need to specify the appropriate channel :

```
<MODULE1> (channel_data1)
```

To connect two modules together we need to create a channel which takes one of the outputs of the first module. To do this we use the `.out` which allows us to select the outputs of the first module and finally we specify which of the module's outputs we want :

```
channel_module2 = <MODULE1>.out.<output>
<MODULE2> (channel_module2)
```

When a module requires multiple inputs, we don't create several channels. We create one that contains the different inputs required by the modules. To do this, you need an operator. One of the most useful is `.join`. Attention the order is important and must correspond to the desired order in the module :

```
channel_module3 = <MODULE2>.out.<output>.join(channel_data1).join(channel_data2)
<MODULE3> (channel_module3)
```

> [!NOTE]
> There are different types of operator depending on your needs. For a complete list, please refer to the nextflow documentation: : https://www.nextflow.io/docs/latest/operator.html#

> [!WARNING]
> The same applies to workflows, you can link modules to workflows and vice versa.

At the same time, we need to edit the version files of our various modules. To do this, the first thing to do in the main is to create an empty channel:

```
ch_versions = Channel.empty()
```

Then, at the end of each module, incorporate the module version into the channel version.

```
channel_module2 = <MODULE1>.out.<output>
<MODULE2> (channel_module2)
ch_versions = ch_versions.mix(<MODULE2>.out.versions.first())
```

#### define your Workflow outputs.

Once your `main` finish you can define the output that you want from you different modules or workflows.
A workflow can declare one or more output channels using the `emit` keyword.

```
emit:
    output1 = <MODULE1>.out.<output> // channel: [ val(meta), [ output ] ]
    output2 = <MODULE2>.out.<output> // channel: [ val(meta), [ output ] ]
```

> [!NOTE]
> As with `main`, you can create outputs containing several files using operators.

Don't forget to also define the output for the version file :

```
    versions = ch_versions // channel: [ versions.yml ]
```

### Editing `./subworkflows/nf-scil/<name_of_your_workflow>/meta.yml` :

Fill the sections you find relevant. There is a lot of metadata in this file, but we
don't need to specify them all. At least define 3 `keywords`, describe the workflow'
`inputs` and `outputs` in the order in which they appear, and add a `short description` for the use of the subworkflow.

### Editing `./test/subworkflows/nf-scil/<name_of_your_workflow>/main.nf` :

- define the channels of your different inputs.
  > You can check the possibilities given by nf-core to include your dataset in the nextflow documentation : https://www.nextflow.io/docs/latest/channel.html .

### Editing `./test/subworkflows/nf-scil/<name_of_your_workflow>/nextflow.config` :

## Run the tests to generate the test metadata file

## Last safety test

## Submit your PR
