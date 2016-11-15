<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero README</title>
            <link rel="stylesheet" type="text/css" href="../doc.css">
            <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans:300,300italic,400,400italic,600,600italic%7CNoto+Serif:400,400italic,700,700italic%7CDroid+Sans+Mono:400">
            <style>
                .markdown-body {
                    box-sizing: border-box;
                    min-width: 200px;
                    max-width: 980px;
                    margin: 0 auto;
                    padding: 45px;
                }
            </style>
</head><article class="markdown-body">

# Vaquero

[Home](https://ciscocloud.github.io/vaquero-docs/) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master) | [Project Requirements](https://ciscocloud.github.io/vaquero-docs/docs/current/requirements.html)

[![Build Status](https://drone.projectshipped.io/api/badges/CiscoCloud/vaquero/status.svg)](https://drone.projectshipped.io/CiscoCloud/vaquero)

- [Private Dev Repo](https://github.com/CiscoCloud/vaquero) : Vaquero's development home
- [Waffle.io Issue Tracking](https://waffle.io/CiscoCloud/vaquero): Progress tracking tool

A bare metal configuration utility that network boots machines based on user defined templates. We leverage iPXE and support cloud-config, ignition, kickstart, and untyped unattend boot scripts.

The only thing you need pre-installed to run Vaquero is [Docker](https://www.docker.com/).

See the [Getting Started](https://ciscocloud.github.io/vaquero-docs/docs/current/getting-started.html) page for details on deploying Vaquero in virtualbox.

# [Architecture](https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html)
![](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/arch-revision.png)

## [Data Model Templates](https://ciscocloud.github.io/vaquero-docs/docs/current/data-model-howto.html)
Data Models are used by Vaquero as the "Source of Truth" to describe your data center. Data Models define machine operating systems, subnets, and boot scripts. We provide some [example data models](https://github.com/CiscoCloud/vaquero-examples) as a reference to build your own.

Two notable branches in the example repo:

- [`master`](https://github.com/CiscoCloud/vaquero-examples): This will be updated to reflect a complete data model for reference. We will keep this single branch updated when an example of every supported feature, model type, and workflow is up. The master branch will be configured to run on localhost.

- [`vagrant`](https://github.com/CiscoCloud/vaquero-examples/tree/vagrant): Used for small deployments via vagrant in virtualbox. This branch may not show every feature, but it will be leveraged as a small scale example Data Model to deploy a few machines at most. This branch will contain a data model that will include definitions for the demos. See the [Getting Started](https://ciscocloud.github.io/vaquero-docs/docs/current/getting-started.html) page for for more info about the demos.

## Configuring and Running Vaquero

The diagram below depicts what a production (multi-agent, multi-server) deployment of Vaquero might look like.
![](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/many-vaqueros.png)

Vaquero can run in multiple modes: `server`, `agent`, and `standalone`. "Standalone" refers to running server and agent in the same container. A standalone configuration file, combining information needed to run both agent and server, is shown below.

See the [architecture page](https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html) for more details about server and agent.

************************************************************
**sample-standalone-config.yaml:**
```
ServerApi:
  Address: "127.0.0.1"
  Port: 24601
AgentApi:
  InsecureAddr: "127.0.0.1"
  InsecurePort: 24604
AssetServer:
  Addr: "127.0.0.1"
  Port: 24602
  BaseDir: "/var/vaquero/files"
  Scheme: http
DHCPMode: server
SavePath: "/var/vaquero"
Etcd:
  Endpoints:
  - "http://127.0.0.1:2379"
  Timeout: 5
  Retry: 3
Gitter:
  Endpoint: "/postreceive"
  Timeout: 2
  Addr: "127.0.0.1"
  Port: 24603
GitHook:
  - ID: "vaquero-master"
    Token: <GIT_TOKEN>
    URL: "https://github.com/CiscoCloud/vaquero-examples"
    Secret: supersecretcode
SoT:
- Git:
    HookID: "vaquero-local"
    ID: "vaquero-test"
    Branch: local
Log:
  Level: info
  Location: stdout
  LogType: text

```
************************************************************
### Configuration Fields Overview
- `ServerApi`: The user api for the server. Currently not implemented.
- `AgentApi`: The vaquero-agent http server used to listen for Vaquero server commands.
- `AssetServer`: The asset server for Vaquero agent used by each booting machine to get unattended scripts and kernels.
- `SavePath`: The Vaquero server location to save local configurations on disk.
- `Gitter`: Configuration for listening to git webhooks.
- `GitHook`: An array for all githooks to listen to.
- `SoT:` An array for specific sources of truth. Git updater receives webhooks from github. Local: will use a local directory to update.
- `Etcd`: (for a vaquero server cluster / HA) specifies the information used to connect a running etcd cluster to vaquero's own Etcd client. Etcd is used to keep track of state, data models, and other information in a persistent, distributed KV store.
- `DHCPMode`:Using "server" runs Vaquero as a DHCP server.  Vaquero does not manage free address pools or leases; it simply assigns based of the static configuration defined in the data model. **Note that DHCPMode defaults to server.** Using "proxy" enables ProxyDHCP. ProxyDHCP works with an existing DHCP Server to provide PXEBoot functionality, while leaving the managing and assigning of IP addresses to the other DHCP Server. Only enable this if you already have a DHCP server with entries for all the hosts in your Data Model.


### Configuration Fields In Detail

(Fields indicated as "Agent" and "Server" are by default included in Standalone mode. Forward-slashes in field names indicate YAML hierarchy)

| Mode   | Name                  | Required? | Description                                                                | Default            |
|--------|-----------------------|-----------|----------------------------------------------------------------------------|--------------------|
| All    | Log/Level             | no        | Minimum Logging Level (debug, info, warning, error, fatal, panic)          | info               |
| All    | Log/Location          | no        | Place to log: (stdout, stderr, `filename`)                                 | stdout             |
| All    | Log/Type              | no        | Text / JSON output (text/json)                                             | text               |
| All    | SavePath              | no        | Base folder for vaquero save files                                         | /var/vaquero       |
| All    | Gitter/Endpoint       | no        | githook endpoint to receive webhooks                                       | /postreceive       |
| All    | Gitter/Address        | no        | githook listening address                                                  | 127.0.0.1          |
| All    | Gitter/Port           | no        | githook listening port                                                     | 24603              |
| All    | Gitter/Timeout        | no        | githook timeout, in seconds                                                | 2                  |
| All    | GitHook/ID            | no        | githook ID                                                                 | none               |
| All    | GitHook/Token         | no        | hook token, generated on github/settings                                   | none               |              |
| All    | GitHook/URL           | no        | url for githook                                                            | none               |
| All    | GitHook/Secret        | no        | secret for githook                                                         | none               |
| Agent  | AgentAPI/InsecureAddr | no        | IP Address on which to serve the agent REST API                            | 127.0.0.1          |
| Agent  | AgentAPI/InsecurePort | no        | Port on which to serve the agent REST API                                  | 24602              |
| Agent  | Assets/CdnScheme      | no        | Cdn scheme                                                                 | none               |
| Agent  | Assets/CdnAddr        | no        | The address of the cdn endpoint to reverse proxy to                        | http               |
| Agent  | Assets/CdnPort        | no        | The port of the cdn endpoint to reverse proxy to                           | 0             |
| Agent  | AssetServer/Addr      | no        | The IP Address to serve the agent asset server                             | 127.0.0.1          |
| Agent  | AssetServer/Port      | no        | The port to serve the agent asset server                                   | 20468              |
| Agent  | AssetServer/Scheme    | no        | Asset server scheme : http / https                                         | http               |
| Agent  | AssetServer/BaseDir   | no        | Agent directory to serve files from                                        | /var/vaquero/files |
| Agent  | DHCPMode              | no        | Agent DHCP Mode: server / proxy                                            | server             |
| Server | ServerAPI/Address     | no        | The IP Address to serve the server REST API on                             | 127.0.0.1          |
| Server | ServerAPI/Port        | no        | The port to serve the server REST API on                                   | 24601              |
| Server | Etcd/Endpoints        | no        | s/etcd database endpoints/etcd initial cluster endpoints: format- e1,e2,e3 | 127.0.0.1:2379     |
| Server | Etcd/Retry            | no        | number of retries for etcd operations                                      | 3                  |
| Server | Etcd/Timeout          | no        | etcd dial and request timeout, in seconds                                  | 5                  |
| Server | SoT/Git/HookID        | yes       | git hookID                                                                 | none               |
| Server | SoT/Git/ID            | yes       | ID (?)                                                                     | none               |
| Server | SoT/Git/Branch        | yes       | SoT branch name                                                            | none               |

## Running Vaquero from the container
[Bintray Docker Images](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero)

1. Fetch the image: `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
2. Run the example: `docker run -v /vagrant/vagrant-config.yaml:/vaquero/config.yaml -v /files:/tmp/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

    1. `docker volume` to pass the configuration into the container.
    2. `docker volume` to pass in the assetServer assets (kernel images, `undionly.kpxe`, etc)
    3. set networking to `host`

## Vaquero with Systemd
Vaquero can be started as a service using Systemd and Docker.

**/etc/systemd/system/vaquero.service**
************************************************************
```
[Unit]
Description=Vaquero Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run --net host -v /var/vaquero/config.yaml:/config.yaml -v /var/vaquero/files:/var --name Vaquero shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /config.yaml
ExecStop=/usr/bin/docker stop vaquero
ExecStopPost=/usr/bin/docker rm -f vaquero

[Install]
WantedBy=default.target
```
************************************************************

This example does:

1. Starts a Docker container named `vaquero` after the Docker service has started.
2. It starts using the parameters passed into `ExecStart`
3. `ExecStop` stops the `vaquero` container and is run when stopping the service.
4. `ExecStopPost` removes the `vaquero` container and is run after stopping the service.
5. It tries to restart the service.

Tips:

1. Make sure the Docker service is enabled on startup `sudo systemctl enable docker`
2. Check that the `vaquero` service isn't dying `sudo systemctl status vaquero`
3. See if the Docker container exists `sudo docker ps`
4. Flush the changes `sudo systemctl daemon-reload`
5. Restart both the `docker` and the `vaquero` services `sudo systemctl restart docker`
6. Make sure that pathing is correct for config and files required

## [Vaquero Validate](https://ciscocloud.github.io/vaquero-docs/docs/current/validator.html)
CLI tool that is for validating your data model before you push it through Vaquero

## Sending Webhooks to Vaquero Master

1. Install [ngrok](https://ngrok.com/) to your local machine, unzip the package, and move the executable to `/usr/local/bin`.
2. Run ngrok on your physical machine `ngrok http 127.0.0.1:4816` or `ngrok http 4816`.
    1. Make sure that the address and port are the same as the Git Hook server in the config.
    2. It should follow `ngrok http <Gitter.Addr>:<Gitter.Port>`
3. Create a testing repo to launch webhooks from.
4. Give github.com the http endpoint provided by ngrok `http://0000ffff.ngrok.io/postreceive/vaquero-local`.
    1. This should be something like `<ngrok address>/<Gitter.Endpoint>/<GitHook.ID>`.
    2. The `Gitter.Endpoint` and the `GitHook.ID` are from the config.
5. Launch a webhook to hit the ngrok address.
    1. The `GitHook.Username`,`GitHook.Password`, and `GitHook.Secret` should be set in configuration to connect to the webhook of the `GitHook.URL`.
    2. Note that the `GitHook.Secret` can be left blank and should correspond to the Secret created when setting up the webhook on GitHub.
    3. Pushing to the repo, or `Redeliver Payload` on GitHub will launch a webhook.

## Docs
Build the documentation by running `godoc -http <port>` and open `localhost:<port>` on your web browser


## Questions / Comments / Feedback
To provide feedback to the team please email: [vaquero-feedback@external.cisco.com](mailto:vaquero-feedback@external.cisco.com)
For Issues, open at [CiscoCloud/vaquero-docs](https://github.com/CiscoCloud/vaquero-docs/issues)
