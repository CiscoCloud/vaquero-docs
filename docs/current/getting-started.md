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


## [Virtual environment](https://github.com/CiscoCloud/vaquero-vagrant)
- Deploying vaquero via Vagrant on VirtualBox VMs. Validated on OSX and Windows. The vaquero base VM is Centos7 that has docker installed, kernels and initrds as well.

[Intro Video : Running the VM](https://cisco.box.com/s/tmd818xyj1126kf7nxqmimtxtuy7fxfr)

[Video : Running the container and booting a machine](https://cisco.box.com/s/7n84iungc6u0k0i9yxct04skgbp1fmpg)

## 1. clone the vagrant repo

`git clone https://github.com/CiscoCloud/vaquero-vagrant.git && cd vaquero-vagrant`


## 2. starting VM(s) to run vaquero on
Firstly we can run vaquero in standalone mode or in separated server and agent modes. Standalone is both modes running out of the same container and its intended use is for testing and POCs. Production deployments should have multiple servers and agents that are separate. (As I write this in early November 2016, we are in progress for HA servers)

Lets look at some ENVIRONMENT variables to decide how to set up the VM infrastructure.
- `VS_NUM`: An integer number of how many vaquero server VMs to start. Default: 1 (this can be used for standalone mode)
- `VA_NUM`: An integer number of how many vaquero agent VMs to start
- `V_DEV`: A 0 or non-zero integer that will allocate more resources to the VM. By default we allocate 1 vCPU and 512MBs of RAM, enabling `V_DEV` allocates 2 vCPUs and 2048MBs of RAM.
- `V_RELAY`: A 0 or non-zero integer that will set up vaquero to be deployed on a separate subnet from its booting hosts. It will also set up a dual homed `gateway` machine that will forward packets between the subnets.

By default we only set `VS_NUM=1`.

- To deploy one vaquero VM to run standalone mode. `vagrant up`

- To deploy one vaquero server and one vaquero agent. `VA_NUM=1 vagrant up`

- To deploy 3 vaquero servers and 3 vaquero agents with the relay. `VS_NUM=3 VA_NUM=3 V_RELAY=1 vagrant up`

  #### Beware
  **NOTE: you must set these environment variables in your session or prepend the ENV vars to every `vagrant` command.**

  For example: `VS_NUM=3 vagrant up` will stand up 3 vaquero server VMs. Running `vagrant destroy -f` will only destroy the first instance, you must run `VS_NUM=3 vagrant destroy -f` to clean up all of them. Include *every* ENV var for *every* vagrant command, even things like `vagrant ssh vs-3`.

## 3. pull the latest docker image

`docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`


## 4. run vaquero with 1 of the source of truth types (we default DHCP to run in server mode)

If you want to run vaquero in DHCP proxy mode, edit the configuration in `config/` and start the dnsmasq VM by running: `vagrant up dnsmasq`. This will stand up dnsmasq VM running a DHCP server that only serves IP addresses.

See the different [configurations](https://github.com/CiscoCloud/vaquero-docs/tree/VagrantEnv/config).

##### Git SoT:

`docker run -v /vagrant/config/git-sot.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

##### Dir SoT:

`docker run -v /vagrant/config/dir-sot.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files -v /vagrant/local:/vagrant/local --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`


## demo lab

Vaquero provides this vagrant environment as a sandbox to work with vaquero before actual deployment. We also provide a few different demos to showcase what vaquero has to offer and how the data model is set up.

### Demo Lab layout

#### Vagrant VM Table
There are `*`'s in the third space because VMs can be on the 10.10.10.0/24 or the 10.10.11.0/24 network. If no http relay is in effect all machines will be on the 10.10.10.0/24 network, if relay is active, vaquero services will be moved to 10.10.11.0/24 while booting hosts will be on 10.10.10.10/24


| Vagrant VM     | IP Address               |
|:---------------|:-------------------------|
| Relay gateway  | 10.10.10.3 & 10.10.11.3  |
| Free           | 10.10.\*.4               |
| Vaquero server | 10.10.\*.5 - 10.10.\*.7  |
| Vaquero agent  | 10.10.\*.8 - 10.10.\*.10 |


#### Booting Host Table


| Mac address       | IP Address  | Demo          |
|:------------------|:------------|:--------------|
| 00:00:00:00:00:01 | 10.10.10.11 | SANDBOX       |
| 00:00:00:00:00:02 | 10.10.10.12 | SANDBOX       |
| 00:00:00:00:00:03 | 10.10.10.13 | SANDBOX       |
| 00:00:00:00:00:04 | 10.10.10.14 | SANDBOX       |
| 00:00:00:00:00:05 | 10.10.10.15 | SANDBOX       |
| 00:00:00:00:00:06 | 10.10.10.16 | SANDBOX       |
| 00:00:00:00:00:07 | 10.10.10.17 | SANDBOX       |
| 00:00:00:00:00:08 | 10.10.10.18 | SANDBOX       |
| 00:00:00:00:00:09 | 10.10.10.19 | SANDBOX       |
| 00:00:00:00:00:21 | 10.10.10.21 | core-cloud    |
| 00:00:00:00:00:22 | 10.10.10.22 | core-cloud    |
| 00:00:00:00:00:23 | 10.10.10.23 | core-cloud    |
| 00:00:00:00:00:24 | 10.10.10.24 | core-cloud    |
| 00:00:00:00:00:31 | 10.10.10.31 | core-ignition |
| 00:00:00:00:00:32 | 10.10.10.32 | core-ignition |
| 00:00:00:00:00:33 | 10.10.10.33 | core-ignition |
| 00:00:00:00:00:34 | 10.10.10.34 | core-ignition |
| 00:00:00:00:00:41 | 10.10.10.41 | centos        |



## canned demos
This assumes there is a running vaquero instance as described above with either the provided github repo or local data model.

[Video](https://cisco.box.com/s/lsohd9v7ik1rx1af3fthng1w87o9ig36)

- etcd cluster on Coreos via cloud-config: `./create-cluster/cluster.sh -d core-cloud`

- etcd cluster on Coreos via ignition: `./create-cluster/cluster.sh -d core-ignition`

- Centos7 base via kickstart: `./create-cluster/cluster.sh -d centos`


### using the sandbox mac space via github

1. Go through steps 1-4.
2. add your git token to the vaquero configuration
    - `./provision_scripts/replace.sh <GIT_TOKEN>`
3. Create your own github repo to contain your own data model
4. If your machine is not routable set up [ngrok and the githook as described in the README](https://ciscocloud.github.io/vaquero-docs/docs/current/README.html)
5. Create your own vaquero configuration based off `config/git-sot.yaml` examples. Update the Gitter fields (URL) and SoT (branch) section to reflect your repo.
6. Start vaquero and ensure the zipball API info log refers to your repo and is a success
7. Update your github repo, see webhook
8. Run `./create-cluster/cluster -c <count>` to start <count> VM's starting at mac `:01` and counting up

[Video](https://cisco.box.com/s/b4d4d5v3i3yph4lvcoplydqny7p6qun4)

### using the sandbox mac space via local dir

1. Go through steps 1-4
2. Update the `local/` data model.
3. Run `./create-cluster/cluster -c <count>` to start <count> VM's starting at mac `:01` and counting up

[Video](https://cisco.box.com/s/cbvci60f1v6b3bcajq2ejtfizr3z0ss6)

### [Running the validator](https://ciscocloud.github.io/vaquero-docs/docs/current/validator.html)
After sshing into the vagrant VM, with the container on it.

Validator using a git repo
`docker run -v <SRC_CFG>:<DEST_CFG> shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest validate --config <DEST_CFG>`

Validator using a local dir
`docker run -v <SRC_DIR>:<DEST_DIR> shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest validate --sot <DEST_DIR>`
