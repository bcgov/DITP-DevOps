# ArgoCD Implementation

## Shared Goals
- Automate deployments of services to dev / test / prod
- Automate GitOps driven infrastructure (CrunchyBD, monitoring, other resources)
- Automate GitOps driven cluster access (team access RBAC, roles, role bindings, sysdig teams, etc)


### Projects - In Scope
| Project Name                         | License Plate | Configured (Managed by ArgoCD) |
| ------------------------------------ | ------------- | :----------------------------: |
| Digital Trust Demo Apps              | a99fd4        |               no               |
| Digital Trust Monitoring Services    | ca7f8f        |              yes               |
| Digital Trust Services Trust Over IP | e79518        |              yes               |
| Digital Trust Shared Service         | 4a9599        |               no               |
| Traction                             | bc0192        |              yes               |

### Projects - Out of Scope
| Project Name | License Plate |
|---------|----------------|
| OrgBook | 8ad0ea |
| BC Registries Agent | 7cba16 |

---
## Current Deployable Resources And Configurations

**Traction** GitHub [repo](https://github.com/bcgov/traction):
- `Traction` Helm chart
- `PR` deployment values
- `dev` deployment values

**Trust Over IP Configurations** [repo](https://github.com/bcgov/trust-over-ip-configurations/) :
- Traction `test`, `prod` deployment values
- vc-authn-oidc `dev`/`test`/`prod` deployment values
- Infrastructure / Monitoring stack -- Currently in PR [(https://github.com/bcgov/trust-over-ip-configurations/pull/181)](https://github.com/bcgov/trust-over-ip-configurations/pull/181)
- The following are managed with the [openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) scripts, which uses a managed OCP template + parameter file approach. 
    - Tails Server - `dev`/`test`/`prod`
    - Shared Redis Cluster - `dev`/`test`/`prod`
    - Issuer Agent Instances  - `dev`/`test`/`prod`
        - LSBC
        - IDIM - `dev`/`sit`/`qa`/`pre-prod`/`prod`
        - LCRB (Issuer and Controller)
        - BC Reg (Different than the BC Registries Agent)
    - Issuer Kit Instances - _**Deployed to Digital Trust Demo Apps**_
        - A2A - `dev`/`test`
            - For issuing fake LSBC style credentials for testing.
        - BC VC Pilot - `dev`/`test`/`prod`

**Essential Services Delivery Configurations** [repo](https://github.com/bcgov/essential-services-delivery)
  - Managed with the [openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) scripts
  - Issuer Kit Instances - _**Deployed to Digital Trust Demo Apps**_
    - Open VP - `dev`/`test`/`prod`
      - For issuing unVerified Person credentials for testing.
    - Open VP - CANdy - `dev`/`test`/`prod`
      - For issuing unVerified Person credentials for testing.

**BC Registries Audit Script and Configurations** [repo](https://github.com/bcgov/von-bc-registries-audit)
  - [GitHub Actions Pipeline](https://github.com/bcgov/von-bc-registries-audit/tree/main/.github/workflows)
  - Also has a lagacy [openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) script configuration.
  - BC Registries Audit Script Container - only active in `prod`
      - Deployed to Digital Trust Monitoring Services

**Aries Endorser Service Configurations** [repo](https://github.com/bcgov/dts-endorser-service)
- [openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) script configuration.
- GitHub Actions Pipeline - [PR](https://github.com/bcgov/dts-endorser-service/pull/37)
- Deploys to Digital Trust Shared Service
- Endorcer Service - CANdy - `dev`/`test`/`prod`
- Endorcer Service - BCovrin - `dev`/`test`/`prod`
- Endorcer Service - Sovrin - `test`/`prod`

**Aries Mediator Configurations** [repo](https://github.com/bcgov/openshift-aries-mediator-service)
- [openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) script configuration.
- Deploys to Digital Trust Shared Service
- Mediator Service - `dev`/`test`/`prod`
- Shared Redis Cluster - `dev`/`test`/`prod`

**Allure Framework OpenShift** [repo](https://github.com/BCDevOps/allure-framework-openshift)
- [openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) script configuration.
- Deploys to Digital Trust Shared Service
- Allure Services - `prod`
    - Used for AATH test reporting.
- Allure Services - Mobile - `prod`
    - User for MATH test reporting.

**Indy Email Verification Service** [repo](https://github.com/bcgov/indy-email-verification)
- [openshift-developer-tools](https://github.com/BCDevOps/openshift-developer-tools/tree/master/bin) script configuration.
- Will be retired
- Deployed to Digital Trust Demo Apps

**Buy BC**
- Not In Scope
- Emiliano has the details
- Buy BC Issuer Agent - `dev`/`test`/`prod`
    - Deployed into the Digital Trust Services Trust Over IP namespace

**VC-AuthN-OIDC** [repo](https://github.com/bcgov/vc-authn-oidc/):
- `vc-authn-oidc` Helm Chart

**DITP-DevOps** [repo](https://github.com/bcgov/DITP-DevOps):
- SysDigTeam CR objects

# Implementation

### GitOpsAlliance Custom Resource

A `GitOpsAlliance` CR object, `ditp` has been created in the `ca7f8f-tools` namespace.
This manifest is used to manage access to the ArgoCD project and the repository. A GitOpsAlliance is used to setup a single, umbrella ArgoCD project to manage resources in multiple Openshift projects.

The GitOpsAlliance `ditp` is also used to specify namespace labels to match desired project.
Once the list of projects/namespaces is determined, the platform team is responsible for configuring the namespaces with the set label. 

For making changes to the list of namespaces (to add/remove) please contact the platform team.

---
# GitOps Repository

A GitOps GitHub repository, [`bcgov-c/ministry-gitops-ditp`](https://github.com/bcgov-c/ministry-gitops-ditp) has been created for our use.
### Repo Directory Structure

```
.
├── README.md
├── .argocd
│   ├── bc0192-traction
│   │   ├── dev
|   |   |   ├── traction.dev.app
|   |   |   ├── traction-database.app.yaml
|   |   |   └── monitoring-agent.app.yaml
│   │   ├── test
|   |   |   ├── traction.test.app
|   |   |   ├── traction-database.app.yaml
|   |   |   └── monitoring-agent.app.yaml
│   │   ├── prod
|   |   |   ├── traction.prod.app
|   |   |   ├── traction-database.app.yaml
|   |   |   └── monitoring-agent.app.yaml
│   │   └── tools
|   |       └── monitoring-agent.app.yaml
│   ├── e79518-toip
│   │   ├── dev
|   |   |   ├── vc-authn-oidc.dev.yaml
|   |   |   ├── crunchy-cluster.yaml
|   |   |   └── monitoring-agent.app.yaml
│   │   ├── test
|   |   |   ├── vc-authn-oidc.test.yaml
|   |   |   ├── crunchy-cluster.yaml
|   |   |   └── monitoring-agent.app.yaml
│   │   ├── prod
|   |   |   ├── vc-authn-oidc.prod.yaml
|   |   |   ├── crunchy-cluster.yaml
|   |   |   └── monitoring-agent.app.yaml
│   │   └── tools
|   |       └── monitoring-agent.app.yaml
│   ├── ca7f8f-monitoring
│   │   ├── dev
|   |   |   └── monitoring-agent.app.yaml
│   │   ├── test
|   |   |   └── monitoring-agent.app.yaml
│   │   ├── prod
|   |   |   └── monitoring-agent.app.yaml
│   │   └── tools
|   |       └── monitoring-agent.app.yaml
├── services
│   ├── traction
│   │   └── charts
│   │   │   ├── dev
│   │   │   │   ├── Chart.yaml
│   │   │   │   └── values.yaml
│   │   │   ├── test
│   │   │   │   ├── Chart.yaml
│   │   │   │   └── values.yaml
│   │   │   └── prod
│   │   │       ├── Chart.yaml
│   │   │       └── values.yaml
│   ├── vc-authn-oidc
│   │   └── charts
│   │   │   ├── dev
│   │   │   │   ├── Chart.yaml
│   │   │   │   └── values.yaml
│   │   │   ├── test
│   │   │   │   ├── Chart.yaml
│   │   │   │   └── values.yaml
│   │   │   └── prod
│   │   │       ├── Chart.yaml
│   │   │       └── values.yaml
│   └── crunchy-cluster
│       └── base
│           ├── kustomization.yaml
│           └── postgrescluster.yaml
└── infra
    ├── access
    │   ├── rbac
    │   └── sysdig
    └── monitoring
        ├── agent
        │   └── base
        │       ├── kustomization.yaml
        │       └── (manifests)
        ├── grafana
        │   └── base
        │       ├── grafana-rolebinding.yaml
        │       └── grafana-values.yaml
        ├── loki
        │   └── loki.yaml
        ├── mimir
        │   └── mimir.yml
        └── minio
            └── minio.yml        
```

---
# GitOps Pipelines

Contributions, Resource locations, GitHub Workflows and automations

### Traction
##### Deployments
Deployment of PRs, Dev, Test, and Production environments is accomplished with GitHub workflows, Helm charts, and CR (Custom Resource) manifests for CrunchyData PostgreSQL Clusters.

- PRs: 
PR's are deployed and cleaned up directly by GHA workflows (on_pr_opened.yaml, and on_pr_closed.yaml).
The values file is maintained in-repo (deploy/traction/values-pr.yaml).

- DEV:
Development environment is deployed via GHA workflow. With the `on_push_main.yaml` workflow.

- TEST and PROD
Deployment of the test and production environments is accomplished via the GitOps pipeline, with the combination of GHA workflows and ArgoCD.

Test deployment is entirely automated. Two workflows, `release_assets.yaml` and `chart_release.yaml` are triggered by a new release (`push.tags['v*']`).
**Release Assets** workflow builds, tags, and pushes the container images. And **Helm Chart Release** workflow packages and publishes a new Helm Chart, and automates the upgrade of the `test` deplopyment.

The Helm Chart Release workflow updates chart versions for both, test and prod umbrella charts in the `trust-over-ip-configurations` repo (`services/traction/charts/test|prod`). The workflow then triggers and waits for the GitOps Sync workflow in trust-over-ip-configurations repository. If successful, it triggers an ArgoCD sync of the `bc0192-test-traction` application.

Production environment is left to be manually upgraded by a team member. This is done by logging into [ArgoCD](https://gitops-shared.apps.silver.devops.gov.bc.ca/) and triggering sync for the `bc0192-prod-traction` application.

### VC-AuthN-OIDC
##### Deployments
Deployment of PRs, Dev, Test, and Production environments is accomplished with GitHub workflows, Helm charts, and CR (Custom Resource) manifests for CrunchyData PostgreSQL Clusters. Similar to the Traction pipelines.


---
## Future considerations

### Secret management
There are no known issues of using Vault with either of the implementations above.
