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

[Repo](https://github.com/CiscoCloud/vaquero)

A bare metal configuration tool that takes in templates that describe a data center and automatically network boot those machines into the desired state.

# High Level Overview

## [Architecture](https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html)
![](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/architecturediagram.png)

## [Data Model Templates](https://ciscocloud.github.io/vaquero-docs/docs/current/env-data-structure.html)
- [Data Model How To](https://ciscocloud.github.io/vaquero-docs/docs/current/data-model-howto.html)
- [Example Data Models](https://github.com/gem-test/vaquero)

## [Requirements](https://ciscocloud.github.io/vaquero-docs/docs/current/requirements.html)

## Running Vaquero from the container
[Bintray Docker Images](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero)

1. Fetch the image: `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
2. Run Example: `docker run -v /vagrant/vagrant-config.json:/vaquero/config.json -v /files:/tmp/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.json`

    1. Docker volume to pass the configuration into the container. 
    2. Docker volume to pass in the assetServer assets (kernel images, etc)
    3. Set networking to host

## [Vaquero Validate](https://ciscocloud.github.io/vaquero-docs/docs/current/validator.html)

## Dev Environment: Pre-Reqs

1. [Golang](https://golang.org/) environment
2. [Docker](https://www.docker.com/) 


## Dev Environment: Fetching / Compiling / Running from source

1. `git clone https://github.com/CiscoCloud/vaquero.git $GOPATH/src/github.com/CiscoCloud/vaquero`
2. Build vaquero binary `make`.
3. Run the vaquero binary `.bin/vaquero <command> -config config.json`.


## Sending Webhooks to Vaquero Master

1. Install [ngrok](https://ngrok.com/) to your local machine, unzip the package, and move the executable to `/usr/local/bin`.
2. Run ngrok on your physical machine `ngrok http 4816`.
3. Create a testing repo to launch webhooks from.
4. Give github.com the http endpoint provided by ngrok.
5. Launch a webhook to hit the ngrok address.

## Docs
Build the documentation by running `godoc -http <port>` and open localhost:<port> on your web browser
