# OrgBook Index Sync Uptime Alert Workflow

The following workflow describes the steps to confirm and resolve an index sync alert condition on one of the OrgBook instances.  Addition information regarding the associated error condition and its impact, along with details of the steps to resolve it can be found below.

![index sync decision tree](https://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/bcgov/DITP-DevOps/main/docs/diagrams/index-sync-decision-tree.puml)

## What does an alert look like?

![orgbook-index-sync-alert](./images/orgbook-index-sync-alert.png)

## About OrgBook Indexing

Indexing of credentials received by outside parties such as BC Registries, Liquor and Cannabis Regulation Branch, Ministry of Energy, Mines and Low-carbon Innovation, Ministry of Environment and Climate Change Strategy, and Investment Agriculture Foundation BC, is performed in real-time by the [SolrQueue](https://github.com/bcgov/aries-vcr/blob/master/server/vcr-server/vcr_server/utils/solrqueue.py) class.  This class runs as a threaded process inside OrgBook's (Aries VCR) API.

### What does it mean for indexes to be synchronized?

In short, the indexes are considered synchronized when all records saved to the database have been indexed in `solr`.

### What is the impact of the indexes being out of sync?

Searches and auto-complete in OrgBook rely completely on the `solr` indexes for their results.  When the indexes are not synchronized there are records that exist in the database with no matching index in `solr`.  Those records are essentially hidden from view because they can't be found.

### What affects index synchronization?

There are a few things known to affect indexing and therefore index synchronization:
1. Volume and timing:
    - There can be a slight delay between when credentials are initially received and saved to the database, and when they are indexed (added to the `solr` index).  If a number of records are received simultaneously it can take a bit of time for the indexes to be fully synced.  How long this takes can be influenced by the volume of credentials being received and the duration of time that volume persists.  For example, when an initial data load is being performed the index synchronization process is constantly lagging behind.  In a more steady state scenario the indexing may only lag by a few seconds at a time.
    - These scenarios can cause transient false positive conditions that will clear automatically once the indexing process catches up.
2. Errors in the indexing queue
    - On occasion the indexing queue on an API pod can encounter an error and crash.  Once this occurs and credentials received by this pod will be saved to the database, but they won't be indexed.  This state is characterized by instances of `Error processing real-time index queue` in the API logs. The only way to recover from this is to kill the affected pod and have it replaced.  A rollout is one way to do this; all pods will be replaced.  There are also `RTI_` environment variables that can be set on the API pod that will help automate the process of selectively killing the affected pod when it enters such a condition.
    - These scenarios cause true positive conditions that require the indexes to be synchronized.
3. Unexpected pod evacuations or restarts
    - If a pod has pending indexing work when this occurs the work will be lost, and the indexing won't be completed.
    - These scenarios cause true positive conditions that require the indexes to be synchronized.

## Index synchronization monitoring

The synchronization monitor has been setup to perform a balance between timely detection of true index synchronization issues and detection of false positive conditions.  It checks the state of the indexes every 75 minutes which was selected to minimize the possibility of the monitor running at the same time the BC Registries Agent (which runs every 30 minutes) is performing an update.

## OrgBook Instances

A list of OrgBook instances can be found here; [OrgBook Instances](./orgbook-instances-and-environments.md#orgbook-instances)

## OrgBook OCP Environments

Links to the Deployment Configurations Console can be found here; [Administrator - Deployment Configurations Console](./orgbook-instances-and-environments.md#administrator---deployment-configurations-console)

## orgbook-configurations `./manage` script

General information regarding the bcgov/orgbook-configurations openshift `./manage` script can be found here; [bcgov/orgbook-configurations openshift `./manage` script](./orgbook-configurations-manage-script.md)

Specifics regarding the commands referenced in this workflow can be found here:
- [`indexSynced` command](./orgbook-configurations-manage-script.md#indexsynced-command)
- [`updateSearchIndex` command](./orgbook-configurations-manage-script.md#updatesearchindex-command)

## Performing a rollout

Information on the various ways to perform a rollout can be found here; [Performing a Rollout](./performing-a-rollout.md)