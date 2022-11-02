# The bcgov/orgbook-configurations openshift `./manage` script

The [bcgov/orgbook-configurations](https://github.com/bcgov/orgbook-configurations) repository contains the OCP (OpenShift Container Platform) configurations for the OrgBook instances.  In particular it contains an `openshift` `./manage` script that contains commands for querying and managing the OrgBook environments.  The `./manage` script is built on the [BCDevOps/openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) project.  You will need these tools installed before you can use the `./manage` script.  You will also need to be logged into OCP from the command line before using the script.

For details on the commands supported by the script, and details on how to use them, run `./manage -h`.

## `indexSynced` command

This command can be used to determine whether the OrgBook's indexes are fully synced.

For example:
```
Wade@hvWin10x64 MINGW64 /c/orgbook-configurations/openshift (master)
$ ./manage -p bc -e prod indexSynced

Indexes Synced: true
Indexed Credentials: 11869957
Actual Credentials: 11869957 
```

By default the `indexSynced` command queries the `api/quickload` endpoint for the `prod` environment.  To use it on the `dev` or `test` environments you need to specify the `api/quickload` endpoint for the given environment.

For example:
```
Wade@hvWin10x64 MINGW64 /c/orgbook-configurations/openshift (master)
$ ./manage -p bc -e dev indexSynced https://dev.orgbook.gov.bc.ca/api/quickload

Indexes Synced: true
Indexed Credentials: 159962
Actual Credentials: 159962

Wade@hvWin10x64 MINGW64 /c/orgbook-configurations/openshift (master)
$ ./manage -p bc -e test indexSynced https://test.orgbook.gov.bc.ca/api/quickload

Indexes Synced: false - Difference: 20 (99.9998% complete)
Indexed Credentials: 8666419
Actual Credentials: 8666439
```

## `updateSearchIndex` command

This command can be used to sync the OrgBook's indexes stating on a given date when they are out of sync.

For example (some output from the script was removed for clarity):
```
Wade@hvWin10x64 MINGW64 /c/orgbook-configurations/openshift (master)
$ ./manage -p bc -e prod updateSearchIndex -b 500 -d 2021-11-11T00:00:00Z

Updating the search index ...

Indexing 0 addresss
Indexing 69 credentials
Indexing 61 names
Indexing 36 topics
```
- _If you leave off the `Z` at the end of the date/time specification you will see warnings about a `naive datetime`, but you can safely ignore those warnings._

## `recycle` command

This command is an easy way to recycle one or more pods (or groups of pods in the case of pods that are controlled by horizontal autoscaling).  The command completes once the pod(s) have been scaled to zero and then scaled back up (to at least one running pod).

For example:
```
Wade@hvWin10x64 MINGW64 /c/orgbook-configurations/openshift (master)
$ ./manage -p bc -e test recycle wallet-bc

deploymentconfig.apps.openshift.io/wallet-bc scaled
Waiting for wallet-bc to scale to zero ................

deploymentconfig.apps.openshift.io/wallet-bc scaled
Waiting for wallet-bc to scale up ............
```

## `DeleteTopic` command

This command is used to Delete the specified topic from the OrgBook database.

For example:
```
RACHAUHA@NE022855 MINGW64 /c/git/orgbook-configurations/openshift (main)        
$ ./manage -p bc -e dev deleteTopic BC0002365

Loading settings ...
Loading settings from /c/git/orgbook-configurations/openshift/settings.sh ...   
Loading settings from /c/git/orgbook-configurations/openshift/settings.bc.sh ...switchProject has been deprecated in favor of using the oc -n option to specify 
the target namespace.
Please update your scripts accordingly.
Switching to 8ad0ea-dev ...

If you continue the following topic will be permanently deleted from the OrgBook database; 'BC0002365'.
Would you like to continue?  Press Ctrl-C to exit, or any other key to continue 
...

INFO:snowplow_tracker.emitters:Emitter initialized with endpoint https://spt.apps.gov.bc.ca/i
Enabling realtime indexing ...
Loading custom settings file: custom_settings_bcgov.py
Starting celery with broker pyamqp://User_yiV6wABz:zyxOKBZ8mLj23zjTSozv@msg-queue-bc// and backend db+postgresql://User_dOzU95MP:PUHlCOTEF2hbOF1RUX0o@db-bc/aries-vcr
>>> YES updating cred type timestamp
>>> YES create detail claims for credentials
Deleting topic_id: BC0002365
Deleting wallet credentials ...
 ... 784b5d34-fcd0-4905-8b00-909858decd0d ...
 ... 11ab07da-1ff6-4122-bd1a-96e6d7f91fd5 ...
 ... 207cb2c4-a49c-4e98-a574-16603984f5d7 ...
 ... a6eef99f-f2ce-479b-9819-31f4035eeb28 ...
 ... d989c243-2e29-411c-9bf7-43a8502aa140 ...
 ... cc0600f7-272a-41aa-a942-b0f33e963a56 ...
 ... 61142d96-3e9f-4904-a159-fa1f2b78beff ...
 ... b089ea4a-82ac-42d4-bf69-3901e48bd104 ...
 ... 8d6d7ad1-db51-45b0-972a-7c7ac14449be ...
 ... ad5f2a13-d3fe-4850-8197-9ce877b41cb3 ...
 ... 832748ad-e905-4c35-8c2c-736c68f62796 ...
 ... bc016061-8b46-4241-bf93-1dcd9e4f6c93 ...
 ... b21d2224-a4f2-4f06-854e-6f07da830b2a ...
 ... 143071de-4979-43f7-8ee7-2bd2d4863d90 ...
 ... 6e46ecb1-84a9-42ad-bdc9-f57f08ffe10d ...
Deleting topic from OrgBook search database ...
 ... deleting topic ...
Done.
```