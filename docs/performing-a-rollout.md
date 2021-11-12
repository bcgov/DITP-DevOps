# Performing a Rollout

Performing a rollout can be accomplished either in the OCP console or from the command line.

## Performing a rollout - From the console

1. Log into the OCP console and browse to the [Administrator - Deployment Configurations Console](./orgbook-instances-and-environments.md#administrator---deployment-configurations-console) page of the desired environment.
2. Click on the DeploymentConfig you want to rollout.
3. From the Actions menu select **Start rollout**
4. Monitor the progress in the DeploymentConfig details of the same page.

![rollout](./images/api-rollout.png)

## Performing a rollout - From the cli

Using the `oc` `cli` start the rollout of the desired `dc` in the desired `namespace` and then monitor the rollout using `status`.

For example:
```
Wade@hvWin10x64 MINGW64 /c/orgbook-configurations/openshift (master)
$ oc -n 8ad0ea-prod rollout latest dc/api-bc
deploymentconfig.apps.openshift.io/api-bc rolled out

Wade@hvWin10x64 MINGW64 /c/orgbook-configurations/openshift (master)
$ oc -n 8ad0ea-prod rollout status dc/api-bc
Waiting for rollout to finish: 0 out of 2 new replicas have been updated...
Waiting for rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for rollout to finish: 1 old replicas are pending termination...
Waiting for rollout to finish: 1 old replicas are pending termination...
Waiting for rollout to finish: 1 old replicas are pending termination...
Waiting for latest deployment config spec to be observed by the controller loop...
replication controller "api-bc-51" successfully rolled out
```

To get a list of the `dc`s for a given namespace use `oc -n <namespace> get dc`

For example:
```
Wade@hvWin10x64 MINGW64 /c/DITP-DevOps (main)
$ oc -n 8ad0ea-prod get dc
NAME                  REVISION   DESIRED   CURRENT   TRIGGERED BY
agent-bc              25         4         4         config,image(agent:prod)
api-bc                46         6         6         config,image(api:prod)
backup-bc             4          1         1         config,image(backup:prod)
db-bc                 15         1         1         config,image(db:prod)
db-oli                1          0         0         config,image(db:oli-prod)
frontend-bc           18         3         3         config,image(frontend:prod)
frontend-v2-bc        3          3         3         config,image(frontend-v2:prod)
msg-queue-bc          6          1         1         config,image(msg-queue:prod)
msg-queue-worker-bc   15         2         2         config,image(api:prod)
offline-indexer-oli   1          0         0         config,image(api:oli-prod)
schema-spy-bc         4          0         0         config,image(schema-spy:prod)
search-engine-bc      17         1         1         config,image(search-engine:prod)
search-engine-oli     1          0         0         config,image(search-engine:oli-prod)
wallet-bc             9          1         1         config,image(db:prod)
```


