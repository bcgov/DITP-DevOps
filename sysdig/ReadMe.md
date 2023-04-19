## Setting up a team on Sysdig Monitor

Sysdig Monitor provides system-level monitoring of Kubernetes hosts and the ability to create custom dashboards, alerts and operational-level captures to diagnose application or platform-level issues.

Please refer to the following link - https://docs.developer.gov.bc.ca/sysdig-monitor-setup-team/#sign-in-to-sysdig inorder to set-up a team on Sysdig Monitor.

[e79518-sysigteam.yml](https://github.com/bcgov/DITP-DevOps/blob/main/sysdig/e79518-sysdigteam.yml) is a good example of the sysdig-team custom resource manifest.

Inorder to apply the resource manifest yml file, run the following command replacing with the actual namespace name. 
The commands must be run from the sysdig directory, and you must be logged into OCP

```
cd sysdig/

# apply the manifest
oc -n 4a9599-tools apply -f 4a9599-sysdigteam.yml

# validate that the Sysdig team was created
oc -n 4a9599-tools describe sysdig-team 
```

