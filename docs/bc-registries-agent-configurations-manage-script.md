# The bcgov/bc-registries-agent-configurations openshift `./manage` script

This repository contains the [openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) compatible OpenShift configurations for the [aries-vcr](https://github.com/bcgov/aries-vcr) compatible instance of the [von-bc-registries-agent](https://github.com/bcgov/von-bc-registries-agent).

For information on how to use these configurations with the `openshift-developer-tools scripts` please refer to the documentation; [README.md](https://github.com/BCDevOps/openshift-developer-tools/blob/master/bin/README.md).

In particular it contains an `openshift` `./manage` script that contains commands for querying and managing the BC Registries environments.  The `./manage` script is built on the [BCDevOps/openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) project.  You will need these tools installed before you can use the `./manage` script.  You will also need to be logged into OCP from the command line before using the script.

For details on the commands supported by the script, and details on how to use them, run `./manage -h`.


## `requeueOrganization` command    

This command is used to Requeue a specific company that may have already been processed.


For example:
```
RACHAUHA@NE022855 MINGW64 /c/git/von-bc-registries-audit/openshift (main)
$ ./manage -e prod requeueOrganization 1280573

This command will requeue the specific organisation "1280573" from the BC Registries database in prod environment

<corp_num>, is the corp_num from corp_history_log for the organization to requeue/reprocess.
```
    

## `queueOrganization` command

This command is used to Queue a specific company that has *not* already been processed.

For example:
```
RACHAUHA@NE022855 MINGW64 /c/git/von-bc-registries-audit/openshift (main)
$ ./manage -e prod queueOrganization 1280573


This command will queue the specific organisation "1280573" from the BC Registries database in prod environment

<corp_num>, is the corp_num from BC Registries for the organization to queue/process.
```