# migration-tool

Migration Tool

This migration tool allows to export and import different Sysdig resource. Current version supports only Dashboard export & import but will have more resources added in the future.

This tool is written in Python3.

### Pre-Req

1. Make sure python3 with required libraries is installed.
2. Get Sysdig Monitor API Token (Look at next slide on how to get Sysdig Monitor API Token)

### Setup Env variables

The script requires to have 2 env variables.

| Env Var Name  | Description                | Sample Values | Note |
| ------------- | -------------------------- | --------------- | ---- |
| SYSDIG_ENDPOINT_URL | End point url for Sysdig backend  | West - <https://us2.app.sysdig.com>, East - <https://secure.sysdig.com> 

### How to get Sysdig Monitor API Token

1. Login to your Sysdig UI
2. Click on your Initial Icon at the bottom left
3. Go to Settings
4. Go to User Profile
5. Copy Sysdig Monitor API Token

### Export Dashboard Options

```
python3 sysdig_migrate.py export dashboard <options>
```

### Import Dashboard Options

```
python3 sysdig_migrate.py import dashboard <options>
```

### Export Examples

#### Export all dashboards to <curr dir>/json folder

```
python3 export dashboard --all
```

#### Export all dashboards to /home/dashboards folder

```
python3 export dashboard --all --output_folder="/home/dashboards/"
```

#### Export dashboards based on dashboard ids 3423, 4322, 4343 and 3211 and export them to <curr dir>/json folder

```
python3 export dashboard --ids="3423,4322,4343,3211"
```

### import Examples

#### Import all the dashbaords from <curr dir>/json folders without seeing or approving any plans

```
python3 import dashboard --input_folder="./json/"
```

#### Import all the dashboards from /home/dashboards folder after seeing and approving the plan

```
python3 import dashboard --input_folder="/home/dashboards/" --plan
```

#### Import all the dashboards from /home/dashboards folder with plan info printed but without user needs to manually approve it

```
python3 import dashboard --input_folder="/home/dashboards/" --plan --yes
```

### Common Examples

#### Set the log level to debug

```
python3 import dashboard --input_folder="/home/dashboards/" --plan --log_level=debug
```

#### Set the log folder to /home/dashboards/logs

```
python3 export dashboard --output_folder="/home/dashboards/" --log_folder="/home/dashboards/logs/"
```

### Docker

There is an experimental docker image that can be built and used to run the migration tool.  The docker image is built using the Dockerfile in the root of this repository.  The docker image is built using the following command:

```
docker build -t sysdig-dashboard-migration:latest .
```

The docker image can be run using the following command to export dashboards:

```
docker run --rm -e SYSDIG_ENDPOINT_URL=<https://app.sysdigcloud.com> -e SYSDIG_API_TOKEN=xxxxxxxxxxxxx -v "$(pwd)/json:/app/json" sysdig-dashboard-migration:latest export dashboards --all
```

The docker image can be run using the following command to import dashboards:

```
docker run --rm -e SYSDIG_ENDPOINT_URL=<https://app.sysdigcloud.com> -e SYSDIG_API_TOKEN=xxxxxxxxxxxxx -v "$(pwd)/json:/app/json" sysdig-dashboard-migration:latest import dashboards --input_folder="./json/"
```
