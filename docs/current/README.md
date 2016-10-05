<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Documentation</title>
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

[Home](https://ciscocloud.github.io/vaquero-docs/)

[Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

[![Build Status](https://drone.projectshipped.io/api/badges/CiscoCloud/vaquero/status.svg)](https://drone.projectshipped.io/CiscoCloud/vaquero)

- [Private Dev Repo](https://github.com/CiscoCloud/vaquero) : Vaquero's development home
- [Waffle.io Issue Tracking](https://waffle.io/CiscoCloud/vaquero): Progress tracking tool

A bare metal configuration utility that network boots machines based on user defined templates. We leverage iPXE and support cloud-config, ignition, kickstart, and untyped unattend boot scripts. The only requirement to deploy vaquero is docker. See the [Getting Started](https://ciscocloud.github.io/vaquero-docs/docs/current/getting-started.html) page for details on deploying vaquero in virtualbox.

# [Architecture](https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html)
![](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/ppt-arch.png)

## [Data Model Templates In Depth](https://ciscocloud.github.io/vaquero-docs/docs/current/data-model-howto.html)
Data Models are used by vaquero as the "Source of Truth" to describe your data center. Data Models define machine operating systems, subnets and boot scripts. We provide some [example data models](https://github.com/gem-test/vaquero) as a reference to build your own.

Notable branches in the example repo:

- [`master`](https://github.com/gem-test/vaquero): This will be updated to reflect a complete data model for reference. We will keep this single branch updated when an example of every supported feature, model type, and workflow is up.

- [`local`](https://github.com/gem-test/vaquero/tree/local): Used for CI functional testing. We currently test at two commits in the history. [Init](https://github.com/gem-test/vaquero/commit/3d0df2db8f04eaeaa30e0542d42aa9d861324e4e) and [Update](https://github.com/gem-test/vaquero/commit/b228c2291c3ae87685b25d1435bfe450bf40456b).

- [`vagrant`](https://github.com/gem-test/vaquero/tree/vagrant): Used for small deployments via vagrant in virtualbox. This branch may not show every feature, but it will be leveraged as a small scale example Data Model to deploy a few machines at most.

## [Project Requirements](https://ciscocloud.github.io/vaquero-docs/docs/current/requirements.html)

## Configuring and Running Vaquero
Vaquero can run in multiple modes: `server`, `agent`, and `standalone`. This configuration is for standalone mode, which runs server and agent in the same container. See the [architecture page](https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html) for more details about server and agent.

- See the [Getting Started](architecture page](https://ciscocloud.github.io/vaquero-docs/docs/current/getting-started.html)) page for details on deploying vaquero in virtualbox.

**sample-standalone-config.yaml**
************************************************************
```
---
ServerApi:
 Address: "127.0.0.1"
 Port: 24601
AgentApi:
 InsecureAddr: "127.0.0.1"
 InsecurePort: 24602
AssetServer:
 Addr: "127.0.0.1"
 Port: 8080
 BaseDir: "/tmp/vaquero/files"
 Scheme: http
DHCPMode: server
DHCPCIDR: "127.0.0.1/16"
SavePath: "/tmp/vaquero"
Gitter:
 Endpoint: "/postreceive"
 Timeout: 2
 Addr: "127.0.0.1"
 Port: 9090
GitHook:
 - ID: "vaquero-local"
   Token: <GIT_TOKEN>
   URL: "https://github.com/gem-test/vaquero"
   Secret: <GIT_SECRET>
SoT:
- Git:
     HookID: "vaquero-local"
     ID: "vaquero-test"
     Branch: local
Log:
 Level: debug
 Location: stdout
 LogType: text
```
************************************************************

#### Explanation of config fields:
- ServerApi: The user api for the server. Currently not implemented.
- AgentApi: The vaquero-agent http server used to listen for vaquero server commands.
- AssetServer: The asset server for vaquero agent used by each booting machine to get unattended scripts and kernels.
- DHCPMode: One of two modes, `proxy` or `server`. Leaving the DHCP fields empty will disable all DHCP vaquero functionality.
- DHCPCIDR: The CIDR managed by DHCP.
- SavePath: The vaquero server location to save local configurations on disk.
- Gitter: Configuration for listening to git webhooks.
- GitHook: An array for all githooks to listen to.
- SoT: An array for specific sources of truth.
- Log: The base configuration for the project logr.

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
ExecStart=/usr/bin/docker run --net host -v /var/vaquero/config.yaml:/config.yaml -v /var/vaquero/files:/var --name vaquero shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /config.yaml
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
