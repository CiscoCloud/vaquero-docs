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

[![Build Status](https://drone.projectshipped.io/api/badges/CiscoCloud/vaquero/status.svg)](https://drone.projectshipped.io/CiscoCloud/vaquero)

- [Repo](https://github.com/CiscoCloud/vaquero) : Where development of vaquero is taking place.
- [Waffle.io Issue Tracking](https://waffle.io/CiscoCloud/vaquero): How the team is tracking work and progress

A bare metal configuration utility that network boots machines based on user defined templates. We leverage iPXE and support cloud-config, ignition, kickstart, and untyped.

# High Level Overview

## [Architecture](https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html)
![](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/ppt-arch.png)

## [Data Model Templates](https://ciscocloud.github.io/vaquero-docs/docs/current/data-model-howto.html)
- [Example Data Models](https://github.com/gem-test/vaquero)

The branches to make note of: 

- [`master`](https://github.com/gem-test/vaquero) This will be updated to reflect a complete data model for reference. We will keep this single branch updated when an example of every supported feature / model type / workflow. 

- [`local`](https://github.com/gem-test/vaquero/tree/local) is being used in our CI functional testing. We currently test at two commits in the history. [Init](https://github.com/gem-test/vaquero/commit/3d0df2db8f04eaeaa30e0542d42aa9d861324e4e) and [Update](https://github.com/gem-test/vaquero/commit/b228c2291c3ae87685b25d1435bfe450bf40456b). 

- [`vagrant`](https://github.com/gem-test/vaquero/tree/vagrant) Used for small deployments via vagrant in virtualbox. This branch may not show every feature but it will be leveraged as a small scale example Data Model to deploy a few machines at most.

## [Requirements](https://ciscocloud.github.io/vaquero-docs/docs/current/requirements.html)

## Running / Configuring Vaquero
Vaquero can run in multiple modes `server`, `agent`, and `standalone`. This configuration is for standalone mode, which runs server and agent in the same container. 

**sa-config.yaml**
```
************************************************************
---
ServerApi:
  Address: 127.0.0.1
  Port: 24601
AgentApi:
  InsecureAddr: 127.0.0.1
  InsecurePort: 24602
AssetServer:
  Addr: 127.0.0.1
  Port: 8080
  BaseDir: "/tmp/vaquero/files"
  Scheme: http
DHCPMode: server
DHCPCIDR: 127.0.0.1/16
SavePath: "/tmp/vaquero"
Updater: git
Gitter:
  Endpoint: "/postreceive"
  Timeout: 2
  Addr: 127.0.0.1
  Port: 9090
GitHook:
- ID: vaquero-local
  Username: gem-test
  Password: bc0f9c726d2c4d54c7635eb578c767cc57d89d40
  URL: https://github.com/gem-test/vaquero
  Secret: supersecretcode
SoT:
- HookID: vaquero-local
  ID: vaquero-test
  Branch: local
Log:
  Level: debug
  Location: stdout
  Type: text
  ************************************************************
```

#### Explanation of config fields: 
- ServerApi: The user api for the server. Currently not implemented.
- AgentApi: The vaquero agent http server used to listen for vaquero server commands
- AssetServer: The asset server for vaquero agent used by each booting machine to get unattend scripts and kernels.
- DHCPMode: One of two modes: Proxy or Server
- DHCPCIDR: The CIDR managed by DHCP
- SavePath: The vaquero server location to save local configurations on disk
- Updater: The type of data model updater
- Gitter: Configuration for listening to git webhooks
- GitHook: An array for all gitgooks to listen to
- SoT: An array for specific sources of truth
- Log: The base configuration for the project logr

## Running Vaquero from the container
[Bintray Docker Images](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero)

1. Fetch the image: `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
2. Run Example: `docker run -v /vagrant/vagrant-config.yaml:/vaquero/config.yaml -v /files:/tmp/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

    1. Docker volume to pass the configuration into the container. 
    2. Docker volume to pass in the assetServer assets (kernel images, undionly.kpxe, etc)
    3. Set networking to host

## [Vaquero Validate](https://ciscocloud.github.io/vaquero-docs/docs/current/validator.html)
CLI tool that is for validating your data model before you push it through Vaquero

## Environment: Pre-Reqs

1. [Golang](https://golang.org/)
2. [Docker](https://www.docker.com/) 


## Dev Environment: Fetching / Compiling / Running from source

1. `git clone https://github.com/CiscoCloud/vaquero.git $GOPATH/src/github.com/CiscoCloud/vaquero`
2. Build vaquero binary `make`.
3. Run the vaquero binary `.bin/vaquero <command> -config sa-config.yaml`.


## Sending Webhooks to Vaquero Master

1. Install [ngrok](https://ngrok.com/) to your local machine, unzip the package, and move the executable to `/usr/local/bin`.
2. Run ngrok on your physical machine `ngrok http 4816`.
3. Create a testing repo to launch webhooks from.
4. Give github.com the http endpoint provided by ngrok.
5. Launch a webhook to hit the ngrok address.

## Docs
Build the documentation by running `godoc -http <port>` and open `localhost:<port>` on your web browser

## Questions / Comments / Feedback
To provide feedback to the team please email: [vaquero-feedback@external.cisco.com](mailto:vaquero-feedback@external.cisco.com) 
For Issues, open at [CiscoCloud/vaquero-docs](https://github.com/CiscoCloud/vaquero-docs/issues)
