# BC Registries Audit Notification Workflow

The following workflow describes the steps to confirm and resolve a BC Registries Audit alert notification. Additional information regarding the associated error condition and its impact, along with details of the steps to resolve it can be found below.

<p align="center">
  <img src="https://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/bcgov/DITP-DevOps/main/docs/diagrams/bc-registries-audit-decision-tree.puml">
</p>

## What does an alert look like?

![BC-Registries-Audit-Notification](./images/bc-registries-audit-notification.png)

### Explaination of the alert

In this example, the corporation registration date and corporation name mis-match represents that there is data mis-match between Orgbook and BC Reg. In order to fix the data issue, the topic needs to be deleted in OrgBook, and must be requeued from BC Registries.

Running the./manage commands in following order will solve the data mis-match issue and data disperancy between Orgbook and BC Registries.

The deleteTopic command represents the status of corporation "BC0111208" in OrgBook is incorrect and must be deleted and re-processed.

The requeue command  will requeue the corporation "0111208" and "0441779" in BC Registries if that hasnt already been processed.

The queue command will queue the corporation "1383101" in BC Registries if that hasnt already been processed.

##  About the BC Registries Audit Scripts

### What does it take for the BC Reg and OrgBook data to pass the audit?

The data must exist in both the BC Registries and OrgBook Databases, and the data must match exactly.  To match, the corporation name, corporation status, corporation type, business number, registration number, and  jurisdiction of the business in both BC Registries and OrgBook must all match.


### What is the impact of the data being out of sync?

When the data is out of sync, the data contained in the OrgBook is outdated and incorrect.  Citizens, as well as other companies and services use the OrgBook as a lookup service and rely on this information to be up to date and accurate.


### What affects the audit results?

Audit results are affected by seveal factors:

Manual updates to data in BC registries
- Some updates are made manually and are not associated with event records.  The BC Registry Agent's event processor relies on the event records to detect changes.  Without these records the changes do not get replicated to the OrgBook automatically and the descrepancies will not appear until the audit scripts detect them.

Timing
- The BC Registry Agent's event processor runs on a schedule.  So does the audit script.  The schedule for the audit script is offset from that of the event processor to help ensure the event processor has completed a run before the audit scripts are run.  Even with the offset in the schedules, there are times when the audit script will complete while the event processor still has work to do.  In these cases the audit script will report a descrepancy, most commonly a corp missing from the OrgBook, and by the time you search for the record in the OrgBook the descrepancy has already been rectified.

Networking issues and unexpected pod evacuations or restarts
- When these situations occur, it can affect one or more of the components needed to perform the credential processing on either the BC Registries or OrgBook side.  These situations typically only cause a temporary discrepancy that will be fixed the next time the BC Registry Agent's event processor runs.


### What steps are needed to resolve the issue?

In order to solve the issue above:

Confirm the issue by browsing to ""orgbook.gov.bc.ca"" and search for the corporation number there to verify the issue received in BC Registries Audit Notification still exists.

Once the issue is confirmed

Log into the affected OCP environment and run the scripts in the following order;


```
./manage -p bc -e prod deleteTopic BC0111208
./manage -e prod requeueOrganization 0111208
./manage -p bc -e prod deleteTopic BC0441779
./manage -e prod requeueOrganization 0441779
./manage -e prod queueOrganization 1383101
./manage -e prod runPipeline
```

Running the ```./manage -e prod runPipeline``` script in von bc registries will resolve any timing related issues.

In order to verify, browse to ""orgbook.gov.bc.ca"" and search for the reported corporation numbers to ensure the reported issues are resolved now.

For more details on this script, please refer to [BC Registries Agent Configurations `./manage` script](#bc-registries-agent-configurations-manage-script) and [Orgbook-configurations openshift `./manage` script](#orgbook-configurations-manage-script)

## Digital Trust Monitoring Services OCP Environments

Links to the Deployment Configurations Console can be found here; [Administrator - Deployment Configurations Console](./digital-trust-monitoring-services-environments.md#administrator---deployment-configurations-console)

## BC Registries Agent Configurations `./manage` script

General information regarding the bcgov/von-bc-registries-agent-configurations openshift `./manage` script can be found here; [bcgov/von-bc-registries-agent-configurations `./manage` script](./bc-registries-agent-configurations-manage-script.md)

Specifics regarding the commands referenced in this workflow can be found here:
- [`requeueOrganization` command](./bc-registries-agent-configurations-manage-script.md#requeueOrganization-command)
- [`queueOrganization` command](./bc-registries-agent-configurations-manage-script.md#queueOrganization-command)

## Orgbook-configurations `./manage` script

General information regarding the bcgov/orgbook-configurations openshift `./manage` script can be found here; [bcgov/orgbook-configurations openshift `./manage` script](./orgbook-configurations-manage-script.md)

Specifics regarding the commands referenced in this workflow can be found here:
- [`DeleteTopic` command](./orgbook-configurations-manage-script.md#DeleteTopic-command)

## Audit scripts for Aries VCR/OrgBook and BC Registries Issuer

This repository provides scripts to audit the OrgBook search database and agent wallet against the source BC Registries data; [Audit Scripts](https://github.com/bcgov/von-bc-registries-audit/blob/main/README.md#understanding-the-output)
