# BC Registries Audit Notification Workflow

The following workflow describes the steps to confirm and resolve a BC Registries Audit alert notification. Addition information regarding the associated error condition and its impact, along with details of the steps to resolve it can be found below.

<p align="center">
  <img src="https://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/bcgov/DITP-DevOps/main/docs/diagrams/bc-registries-audit-decision-tree.puml">
</p>

## What does an alert look like?

![BC-Registries-Audit-Notification](./images/bc-registries-audit-notification1.png)
![BC-Registries-Audit-Notification](./images/bc-registries-audit-notification.png)

### What does it mean for the BC Reg and OrgBook data to match (pass the audit)?




### What is the impact of the data being out of sync?




### What affects the synchronization of the data?




### Why data discrepancies are found?



## OrgBook OCP Environments

Links to the Deployment Configurations Console can be found here; [Administrator - Deployment Configurations Console](./orgbook-instances-and-environments.md#administrator---deployment-configurations-console)

## orgbook-configurations `./manage` script

General information regarding the bcgov/orgbook-configurations openshift `./manage` script can be found here; [bcgov/orgbook-configurations openshift `./manage` script](./orgbook-configurations-manage-script.md)


## What causes the alert condition to surface?
In general we see these notifications when the BC Registries Audit scripts detect any discrepancy between the data in the BC Registries database(s) and the data in the OrgBook.

For Example: Corp Type mis-match for: BC1057752; BC Reg: "BEN", OrgBook: "BC"

### What steps needs to be taken to resolve this error?

In order to solve the alert above.

Confirm the alert by browsing to ""Orgbook.gov.bc.ca"" to verify 
the alert received in BC Registries Audit Notification is not false positive by ensuring the data of Orgbook matches with BC Registries;

Once the alert is confimed

Log into the affected OCP environment;


```
./manage -p bc -e prod deleteTopic BC1057752
./manage -e prod requeueOrganization 1057752
```

In this example, the corp type mis-match represents companies Status mis-matching in OrgBook, and must be queued from BC Reg

The first line represents the status of company in OrgBook is incorrect and must be deleted and re-processed.

The commands should be run in the order listed, however, if, for some reason, you need to run the commands in a batch, the `orgbook-configurations` scripts should always be run first.

Commands in the following forms should be run using the openshift `./manage` scripts from [orgbook-configurations](https://github.com/bcgov/orgbook-configurations):
- `./manage -p bc -e <env> deleteTopic <business_number>`

Commands in the following forms should be run using the openshift `./manage` scripts from [von-bc-registries-agent-configurations](https://github.com/bcgov/von-bc-registries-agent-configurations):
- `./manage -e <env> queueOrganization <business_number>`
- `./manage -e <env> requeueOrganization <business_number>`

### DeleteTopic?



## Audit scripts for Aries VCR/OrgBook and BC Registries Issuer

This repository provides scripts to audit the OrgBook search database and agent wallet against the source BC Registries data; [Audit Scripts](https://github.com/bcgov/von-bc-registries-audit/blob/main/README.md#understanding-the-output)
