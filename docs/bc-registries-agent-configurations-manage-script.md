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

## `requeueFailedCreds` command

This command is used to requeue any credentials (credential_log records) that have failed posting.

For example:
```
$ ./manage -e prod requeueFailedCreds

Loading settings ...
Loading settings from /c/Git/von-bc-registries-agent-configurations/openshift/settings.sh ...


Executing command on 7cba16-prod/event-db-primary-8-q6p2q:
        psql -d ${POSTGRESQL_DATABASE} -ac "update credential_log set process_success = null, process_date = null, process_msg = null where process_success = 'N';"

update credential_log set process_success = null, process_date = null, process_msg = null where process_success = 'N';
UPDATE 0
```

## `getPipelineStatus` command

This command will verify the credentials errors that has processed and provide current status of Pipeline.

For example:
```
$ ./manage -e prod getPipelineStatus

Loading settings ...
Loading settings from /c/Git/von-bc-registries-agent-configurations/openshift/settings.sh ...

BC_REG : Table: event_by_corp_filing Processed: 10017043 Outstanding: 27
BC_REG :        event_by_corp_filing Process Errors: 0
BC_REG : Table: corp_history_log Processed: 7775959 Outstanding: 0
BC_REG :        corp_history_log Process Errors: 0
BC_REG : Table: credential_log Processed: 5135210 Outstanding: 0
BC_REG :        credential_log Process Errors: 0
BCREG_LEAR : Table: event_by_corp_filing Processed: 15421 Outstanding: 0
BCREG_LEAR :        event_by_corp_filing Process Errors: 0
BCREG_LEAR : Table: corp_history_log Processed: 14281 Outstanding: 0
BCREG_LEAR :        corp_history_log Process Errors: 0
BCREG_LEAR : Table: credential_log Processed: 23135 Outstanding: 0
BCREG_LEAR :        credential_log Process Errors: 0
```

## `runPipeline` command

This command is used to run the pipeline for the given environment.  It runs the './run-step.sh bcreg/bc_reg_pipeline.py' pipeline script on an instance of a event-processor pod.

For example:
```
$ ./manage -e prod runPipeline

Loading settings ...
Loading settings from /c/Git/von-bc-registries-agent-configurations/openshift/settings.sh ...

>>> NOT Posted webhook level 2 ( 0 ), message Starting bc_reg_event_processor ...
bc_reg_event_processor: ★ 1:00m
bc_reg_event_processor / load_and_process_bc_reg_data: ★ 54.4s
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: ★ 26.4s
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: /data-pipeline/.venv/bin/python3 -u 
"bcreg/find-unprocessed-events.py"
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: >>> Processing 1 of 43 corporations.bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: >>> Processing 43 of 43 corporations.
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Get last processed event for BC_REG
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Last processed event is 17908217 2023-02-21 15:00:00
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Get last max event before now
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Last max event before now is 17908259 2023-02-21 15:07:08
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Get unprocessed corps
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcregistries:Executing: SELECT corp_num, event_id from bc_registries.event
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events:                         where event_timestmp >= %s with 2023-02-21 15:00:00
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcregistries:Loaded corps: 42
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcregistries:Loaded corps: 42
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcregistries:Loaded corps: 1
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Unprocessed corps count is 43
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Find unprocessed events for each corp
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Unprocessed corps events count is 43
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: INFO:bcreg.bcreg_batch_utils:Update 
our queue
bc_reg_event_processor / load_and_process_bc_reg_data / register_un_processed_events: succeeded,  23 seconds
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: ★ 27.6s
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: /data-pipeline/.venv/bin/python3 -u "bcreg/process-corps-generate-creds.py"
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: >>> in scope corp types: {'A': 'EXTRA PRO', 'B': 'EXTRA PRO', 'BC': 'BC COMPANY', 'BEN': 'BENEFIT COMPANY', 'C': 'CONTINUE IN', 'CC': 'BC CCC', 'CP': 'COOP', 'CS': 'CONT 
IN SOCIETY', 'CUL': 'ULC CONTINUE IN', 'EPR': 'EXTRA PRO REG', 'FOR': 'FOREIGN', 'LIC': 'LICENSED', 'LL': 'LL PARTNERSHIP', 'LLC': 'LIMITED CO', 'LP': 'LIM PARTNERSHIP', 'MF': 'MISC FIRM', 'PA': 'PRIVATE ACT', 'QA': 'CO 1860', 'QB': 'CO 1862', 
'QC': 'CO 1878', 'QD': 'CO 1890', 'QE': 'CO 1897', 'REG': 'REGISTRATION', 'S': 'SOCIETY', 'ULC': 'BC ULC COMPANY', 'XCP': 
'XPRO COOP', 'XL': 'XPRO LL PARTNR', 'XP': 'XPRO LIM PARTNR', 'XS': 'XPRO SOCIETY'}
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: Processing: 24.27050841692835
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: >>> Processing 1 of 53 corporations.
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: Processing: 25.531363369897008
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: >>> Processing 53 of 53 corporations.
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: Processing: 25.532547988928854
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: Processing: 44.588754122611135
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: >>> Processing 1 of 10 corporations.
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: Processing: 44.70224084565416
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: >>> Processing 10 of 10 corporations.
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: Processing: 44.73544940492138
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcregistries:Caching data for parties and events ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcregistries:Caching data for corporations ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcregistries:Caching data for code tables ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcreg_core:Caching data for parties and events ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcreg_core:Caching data for corporations ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcreg_core:Caching data for code tables ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcregistries:Caching data for parties and events ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcregistries:Caching data for corporations ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcregistries:Caching data for code tables ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcreg_core:Caching data for parties and events ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcreg_core:Caching data for corporations ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.bcreg_core:Caching data for code tables ...
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: INFO:bcreg.eventprocessor:Didn't complete any activity this loop, so bail
bc_reg_event_processor / load_and_process_bc_reg_data / load_bc_reg_data: succeeded,  45 seconds
bc_reg_event_processor / load_and_process_bc_reg_data / create_bc_reg_credentials: ★ 0.5s
bc_reg_event_processor / load_and_process_bc_reg_data / create_bc_reg_credentials: /data-pipeline/.venv/bin/python3 -u "bcreg/generate-creds.py"
bc_reg_event_processor / load_and_process_bc_reg_data / create_bc_reg_credentials: >>> in scope corp types: {'A': 'EXTRA PRO', 'B': 'EXTRA PRO', 'BC': 'BC COMPANY', 'BEN': 'BENEFIT COMPANY', 'C': 'CONTINUE IN', 'CC': 'BC CCC', 'CP': 'COOP', 'CS': 'CONT IN SOCIETY', 'CUL': 'ULC CONTINUE IN', 'EPR': 'EXTRA PRO REG', 'FOR': 'FOREIGN', 'LIC': 'LICENSED', 'LL': 'LL PARTNERSHIP', 'LLC': 'LIMITED CO', 'LP': 'LIM PARTNERSHIP', 'MF': 'MISC FIRM', 'PA': 'PRIVATE ACT', 'QA': 'CO 1860', 'QB': 'CO 1862', 'QC': 'CO 1878', 'QD': 'CO 1890', 'QE': 'CO 1897', 'REG': 'REGISTRATION', 'S': 'SOCIETY', 'ULC': 'BC ULC COMPANY', 'XCP': 'XPRO COOP', 'XL': 'XPRO LL PARTNR', 'XP': 'XPRO LIM PARTNR', 'XS': 'XPRO SOCIETY'}
bc_reg_event_processor / load_and_process_bc_reg_data / create_bc_reg_credentials: succeeded,  0 seconds
bc_reg_event_processor / load_and_process_bc_reg_data: succeeded, 1 minutes, 8 seconds
bc_reg_event_processor / submit_bc_reg_credentials: ★ 5.6s
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: ★ 5.6s
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: /data-pipeline/.venv/bin/python3 -u "bcreg/submit-creds.py"
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: >>> Processing 5 of 5 credentials.
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: *** Processing: 0.001489824615418911
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: >>> Waiting for all outstanding tasks to complete ...
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: >>> Completed.
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: Processing: 3.961554050911218
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: 75.72785733694468 credentials per minute
bc_reg_event_processor / submit_bc_reg_credentials / submit_credentials: succeeded,  4 seconds
bc_reg_event_processor / submit_bc_reg_credentials: succeeded, 1 minutes, 13 seconds
bc_reg_event_processor: succeeded, 1 minutes, 13 seconds
>>> NOT Posted webhook level 2 ( 0 ), message Ran bc_reg_event_processor - complete.
```