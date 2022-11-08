# Certbot Configurations

These are the OCP build and deployment configurations for deploying [BCDevOps/certbot](https://github.com/BCDevOps/certbot) into the DTS environments.  There are only minor differences to the configurations for each environment.

## Granting the CertBot service account Image Pull permissions

The CertBot service account requires Image Pull permissions to be granted in each environment in which it is deployed.  This can be done using the `grantDeploymentPrivileges.sh` script from [BCDevOps/openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin).

Example:
```
grantDeploymentPrivileges.sh -s certbot -t 4a9599-tools -p 4a9599-prod
```