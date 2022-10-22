# BC Registries Audit Notification Workflow

The following workflow describes the steps to confirm and resolve Error message received from BC Registries Audit. Addition information regarding the associated error condition and its impact, along with details of the steps to resolve it can be found below.

<p align="center">
  <img src="https://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/bcgov/DITP-DevOps/main/docs/diagrams/bc-registries-audit-decision-tree.puml">
</p>

## What does an alert look like?

![BC-Registries-Audit-Notification](./images/bc-registries-audit-notification.png)

## What causes the alert condition to surface?

We observe this kind of error message in von notifications rocket chat channel when there is Corp mis-match status between BC registries and Orgbook environment.

For Example: Corp Status mis-match for: FM0877150 BC Reg: "HIS", OrgBook: "ACT"

### What steps needs to be taken to resolve this error?

Log into openshift:

RACHAUHA@NE022855 MINGW64 /c/git/von-bc-registries-agent-configurations (main)
$ cd openshift/


Run ./manage -p bc -e prod deleteTopic FM0877150   # Run this command in org-book configuration 
Run ./manage -e prod requeueOrganization FM0877150  # Run this command in von-bc-registries-agent-configurations 
Run ./manage -e prod runPipeline # Run this command in von-bc-registries-agent-configurations

Go to orgbook.gov.bc.ca URL and make sure that the Corp Status changes to match now: FM0877150 BC Reg: "HIS", OrgBook: "HIS"

## Audit scripts for Aries VCR/OrgBook and BC Registries Issuer

This repository provides scripts to audit the OrgBook search database and agent wallet against the source BC Registries data; [Audit Scripts](./von-bc-registries-audit/blob/main/README.md#understanding-the-output)
