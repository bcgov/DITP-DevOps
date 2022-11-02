# The bcgov/von-bc-registries-agent-configurations openshift `./manage` script

The [bcgov/von-bc-registries-agent-configurations](https://github.com/bcgov/von-bc-registries-agent-configurations) repository contains the OCP (OpenShift Container Platform) configurations for the BC Registries Agent instances.  In particular it contains an `openshift` `./manage` script that contains commands for querying and managing the BC Registries environments.  The `./manage` script is built on the [BCDevOps/openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) project. You will need these tools installed before you can use the `./manage` script.  You will also need to be logged into OCP from the command line before using the script.

For details on the commands supported by the script, and details on how to use them, run `./manage -h`.


## `requeueOrganization` command    

This command is used to Requeue a specific company that may have already been processed.


For example:
```
RACHAUHA@NE022855 MINGW64 /c/git/von-bc-registries-audit/openshift (main)
$ ./manage -e dev requeueOrganization 0002365

Loading settings ...
Loading settings from /c/git/von-bc-registries-agent-configurations/openshift/settings.sh ...

Executing command on 7cba16-dev/event-db-primary-20-9x4rc:
        psql -d ${POSTGRESQL_DATABASE} -ac "delete from credential_log where corp_num in ('0002365');"

delete from credential_log where corp_num in ('0002365');
DELETE 5

Executing command on 7cba16-dev/event-db-primary-20-9x4rc:
        psql -d ${POSTGRESQL_DATABASE} -ac "delete from corp_history_log where corp_num in ('0002365');"

delete from corp_history_log where corp_num in ('0002365');
DELETE 1

Executing command on 7cba16-dev/event-db-primary-20-9x4rc:
        psql -d ${POSTGRESQL_DATABASE} -ac "update event_by_corp_filing set process_success = null, process_date = 
null, process_msg = null where corp_num in ('0002365');"

update event_by_corp_filing set process_success = null, process_date = null, process_msg = null where corp_num in ('0002365');
UPDATE 1
```
    

## `queueOrganization` command

This command is used to Queue a specific company that has *not* already been processed.

For example:
```
RACHAUHA@NE022855 MINGW64 /c/git/von-bc-registries-agent-configurations/openshift (main)
$ ./manage -e dev queueOrganization BC0002365

Loading settings ...
Loading settings from /c/git/von-bc-registries-agent-configurations/openshift/settings.sh ...

Executing command on 7cba16-dev/event-db-primary-20-9x4rc:
        psql -d ${POSTGRESQL_DATABASE} -ac "insert into event_by_corp_filing (system_type_cd, corp_num, prev_event_id, prev_event_date, last_event_id, last_event_date, entry_date) select 'BC_REG', 'BC0002365', 0, '0001-01-01', last_event_id, last_event_date, now() from event_by_corp_filing where record_id = (select max(record_id) from event_by_corp_filing);"

insert into event_by_corp_filing (system_type_cd, corp_num, prev_event_id, prev_event_date, last_event_id, last_event_date, entry_date) select 'BC_REG', 'BC0002365', 0, '0001-01-01', last_event_id, last_event_date, now() from event_by_corp_filing where record_id = (select max(record_id) from event_by_corp_filing);
INSERT 0 1
```