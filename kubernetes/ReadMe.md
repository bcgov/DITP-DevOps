## Applying manifests

The kustomize folder contains kustomization files for certbot and sysdigteams. The resources are organized by project license plate.
To apply the resources, run the following command with the actual license plate name.

```bash
kubectl apply -k kustomize/4a9599/
```

### More information 
**Sysdigteams**:
_Please refer to the following link - https://docs.developer.gov.bc.ca/sysdig-monitor-setup-team/#sign-in-to-sysdig for details._
_[e79518/sysigteam.yaml](https://github.com/bcgov/DITP-DevOps/blob/main/kubernetes/kustomize/e79518/sysdigteam.yaml) is a good example of the sysdig-team custom resource manifest._
