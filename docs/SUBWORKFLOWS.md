# Adding a new subworkflow to nf-scil

## Generate the template

First verify you are located at the root of this repository (not in `subworkflows`), then run the following interactive command :

```
nf-core subworkflows create
```

It will ask you to give a name for your subworkflow and an author name (use your github username).
Alternatively, you can use the following command to supply directly those informations :

```
nf-core subworkflows create <name> --author <author>
```

## Generate the template

### Edit `./subworkflows/nf-scil/<name_of_your_workflow>/main.nf`

You don’t have the choice to generate an empty template when you generate a subworflow, so the template is based on nf-core.

- remove the different comment lines.
- Include your modules into your subworkflows. Remove the modules `{ SAMTOOLS_SORT}` and `{ SAMTOOLS_INDEX }` then includes yours with the good pathway:

```
include { <MODULES>	} from '../../../modules/nf-scil/<category>/<tool>/main'
```

> [!NOTE]
> You can also include other subworkflows :
>
> ```
> include { <SUBWORKFLOW> } from '../<subworkflow>/main'
> ```

#### Define your Workflow inputs.

A workflow can declare one or more input channels using the `take` keyword.
Multiple inputs must be specified on separate lines:

```
take:
    channel_data1  // channel: [ val(meta), [ data1 ] ]
    channel_data2  // channel: [ val(meta), [ data2 ], [ data3 ] ]
```

> [!NOTE]
> When the `take` keyword is used, the beginning of the workflow body must be defined with the `main` keyword !

#### Fill the `main:` section.

Compose your workflow using the different modules and workflows you've included above.
For inputs channels, use it as follows:

```
<MODULE1> (channel_data1)
```

To connect two modules together you need to create a channel which takes one of the outputs of the first module. To do this, use the `.out` which allows you to select the outputs of the first module. Finally, specify which of the module's outputs you want :

```
channel_module2 = <MODULE1>.out.<output>
<MODULE2> (channel_module2)
```

When a module requires multiple inputs, don't create several channels. Create one that contains the different inputs required by the modules. For this, you need an operator, one of the most useful is `.join`. Attention, here we're talking about inputs and not channels, if one of the elements is part of a channel made up of several elements, you'll need to specify the chosen element. Plus, the order is important and must correspond to the desired order in the module :

```
channel_module3 = <MODULE2>.out.<output>.join(channel_data1).join(channel_data2.data3)
<MODULE3> (channel_module3)
```

> [!NOTE]
> There are different types of operator depending on your needs. For a complete list, please refer to the nextflow documentation: : https://www.nextflow.io/docs/latest/operator.html#

> [!WARNING]
> The same applies to workflows, you can link modules to workflows and vice versa.

At the same time, you need to edit the version files of our various modules. The first thing to do in the main is to create an empty channel:

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

Once the `main` finished you can define the output that you want from the different modules or workflows, be sure to assign just one output per channel. Please list as many outputs as possible for your workflow, so that it can be better reused and adapted.

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

### Edit `./subworkflows/nf-scil/<name_of_your_workflow>/meta.yml`

Fill the sections you find relevant. There is a lot of metadata in this file, but you
don't need to specify them all. At least define 3 `keywords`, describe the workflow'
`inputs` and `outputs` in the order in which they appear, and add a `complete description` for the use of the subworkflow (Use-cases, expected output file, workflow variation based on optional inputs, workflow positioning in relation to other).

## Lint your code

Run prettier on your new module, through the nf-core command line :

```
  nf-core subworkflows \
    --git-remote <your repository> \
    --branch <your branch unless main branch> \
    lint <subworkflow>
```

and fix all errors and as much as the warnings as possible. Refer to this section for further information.

## Submit your PR

Open a PR to the nf-scil repository master. We'll test everything, make sure it's
working and that code follows standards.

Once LGTM has been declared, wave to the maintainers and look at your hard work paying off.

PR merged !
