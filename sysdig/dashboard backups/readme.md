The following readme url - https://github.com/tusharkapadi/migration-tool was used as a reference guide to backup the sysdig dashbords for our current sysdig projects.

Inorder to backup the dashboard JSON files please clone https://github.com/bashfulrobot/sysdig-migration-tool repository and follow the steps shown below using docker desktop:

```
git clone https://github.com/bashfulrobot/sysdig-migration-tool
cd sysdig/
cd migration-tool-main

# The docker image is built using the Dockerfile in the root of this repository. The docker image is built using the following command:

```
docker build -t sysdig-dashboard-migration:latest .
```

# The docker image can be run using the following command to export dashboards:

```
docker run --rm -e SYSDIG_ENDPOINT_URL=<https://app.sysdigcloud.com> -e SYSDIG_API_TOKEN=xxxxxxxxxxxxx -v "$(pwd)/json:/app/json" sysdig-dashboard-migration:latest export dashboards --all (Every project has a unique SYSDIG_API_TOKEN, it can be found in user profile under settings)
```

# The docker image can be run using the following command to import dashboards:

```
docker run --rm -e SYSDIG_ENDPOINT_URL=<https://app.sysdigcloud.com> -e SYSDIG_API_TOKEN=xxxxxxxxxxxxx -v "$(pwd)/json:/app/json" sysdig-dashboard-migration:latest import dashboards --input_folder="./json/"
```

