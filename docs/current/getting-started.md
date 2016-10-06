<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Getting Started</title>
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

# getting started

[Home](https://ciscocloud.github.io/vaquero-docs/)

[Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)


## [Virtual environment](https://github.com/CiscoCloud/vaquero-docs/tree/VagrantEnv)
- Deploying vaquero via Vagrant on VirtualBox VMs. Validated on OSX and Windows. The VM is Centos7 that has docker installed.

## 1. clone the vagrant repo

`git clone https://github.com/CiscoCloud/vaquero-docs.git && git checkout VagrantEnv`


## 2. add your git token

`./provision_scripts/replace.sh <GIT_TOKEN>`


## 3. starting VM to run vaquero with 1 of the DHCP options

- vaquero DHCP server.

    1. `vagrant up vaquero_server`
    2. `vagrant ssh vaquero_server`

- vaquero DHCP proxy with another DHCP server handing out IP addresses to the subnet.

    1. `vagrant up vaquero_proxy dnsmasq`
    2. `vagrant ssh vaquero_proxy`

- other DHCP / TFTP that lists vaquero as "next-server". vaquero is not running any DHCP / TFTP services.

    1. `vagrant up vaquero_dnsmasq`
    2. `vagrant ssh vaquero_dnsmasq`


## 4. pull the latest docker image

`docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`


## 5. run vaquero with 1 of the source of truth types and corresponding DHCP option

See the different [configurations](https://github.com/CiscoCloud/vaquero-docs/tree/VagrantEnv/config).

- `git-*.yaml` uses [github](https://github.com/gem-test/vaquero/tree/vagrant) as a source of truth

    - DHCP server:
    `docker run -v /vagrant/config/git-server.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`
    - DHCP proxy:
    `docker run -v /vagrant/config/git-proxy.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`
    - DHCP other:
    `docker run -v /vagrant/config/git-dnsmasq.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

- `local-*.yaml` uses a [local directory](https://github.com/CiscoCloud/vaquero-docs/tree/VagrantEnv/local) as a source of truth.

    - DHCP server:
    `docker run -v /vagrant/config/local-server.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`
    - DHCP proxy:
    `docker run -v /vagrant/config/local-proxy.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`
    - DHCP other:
    `docker run -v /vagrant/config/local-dnsmasq.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`


## demo lab

Vaquero provides this vagrant environment as a sandbox to work with vaquero before actual deployment. We also provide a few different demos to showcase what vaquero has to offer and how the data model is set up.

### Demo Lab layout
```
|-------------------|-------------|---------------|
|    Mac address    |  IP Address |      Demo     |
|-------------------|-------------|---------------|
| 00:00:00:00:00:01 | 10.10.10.11 | SANDBOX       |
| 00:00:00:00:00:02 | 10.10.10.12 | SANDBOX       |
| 00:00:00:00:00:03 | 10.10.10.13 | SANDBOX       |
| 00:00:00:00:00:04 | 10.10.10.14 | SANDBOX       |
| 00:00:00:00:00:05 | 10.10.10.15 | SANDBOX       |
| 00:00:00:00:00:06 | 10.10.10.16 | SANDBOX       |
| 00:00:00:00:00:07 | 10.10.10.17 | SANDBOX       |
| 00:00:00:00:00:08 | 10.10.10.18 | SANDBOX       |
| 00:00:00:00:00:09 | 10.10.10.19 | SANDBOX       |
|-------------------|-------------|---------------|
| 00:00:00:00:00:21 | 10.10.10.21 | core-cloud    |
| 00:00:00:00:00:22 | 10.10.10.22 | core-cloud    |
| 00:00:00:00:00:23 | 10.10.10.23 | core-cloud    |
| 00:00:00:00:00:24 | 10.10.10.24 | core-cloud    |
|-------------------|-------------|---------------|
| 00:00:00:00:00:31 | 10.10.10.31 | core-ignition |
| 00:00:00:00:00:32 | 10.10.10.32 | core-ignition |
| 00:00:00:00:00:33 | 10.10.10.33 | core-ignition |
| 00:00:00:00:00:34 | 10.10.10.34 | core-ignition |
|-------------------|-------------|---------------|
| 00:00:00:00:00:41 | 10.10.10.41 | centos        |
|-------------------|-------------|---------------|
```

## canned demos
This assumes there is a running vaquero instance as described above with either the provided github repo or local data model.

- etcd cluster on Coreos via cloud-config: `./create-cluster/cluster.sh -d core-cloud`

- etcd cluster on Coreos via ignition: `./create-cluster/cluster.sh -d core-ignition`

- Centos7 base via kickstart: `./create-cluster/cluster.sh -d centos`


### using the sandbox via github

### using the sandbox via local dir
