<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Getting Started</title>
            <link rel="stylesheet" type="text/css" href="../doc.css">
            <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans:300,300italic,400,400italic,600,600italic%7CNoto+Serif:400,400italic,700,700italic%7CDroid+Sans+Mono:400">
                      <link rel='shortcut icon' href='cow.png' type='image/x-icon'/ >
            <style>
                .markdown-body {
                    box-sizing: border-box;
                    min-width: 200px;
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 45px;
                }
            </style>
</head><article class="markdown-body">

# getting started

[Home](https://ciscocloud.github.io/vaquero-docs/) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)


## [virtual environment](https://github.com/CiscoCloud/vaquero-vagrant)
Repo for deploying vaquero via vagrant on VirtualBox VMs. Validated on OSX and Windows. Base VM image is Centos7 with docker, kernels and initrds pre-installed.

[Video : Running the VM](https://cisco.box.com/s/tmd818xyj1126kf7nxqmimtxtuy7fxfr)

[Video : Running the container and booting a machine](https://cisco.box.com/s/7n84iungc6u0k0i9yxct04skgbp1fmpg)

## 1. clone the vagrant repo

`git clone https://github.com/CiscoCloud/vaquero-vagrant.git && cd vaquero-vagrant`


## 2. boot vaquero VMs
Vaquero can run in standalone or in separate server/agent modes. "Standalone" refers to both the agent and server running out of the same container, and is intended for use in testing and in POCs. Production deployments should have multiple (separate) servers and agents. [As of early November 2016, HA servers are in progress.]

Lets look at the ENVIRONMENT variables that can be configured for the VM infrastructure:

  - `VS_NUM`: An integer number of how many vaquero server VMs to start. Default: 1 (this can be used for standalone mode)
  - `VA_NUM`: An integer number of how many vaquero agent VMs to start
  - `V_DEV`: A 0 or non-zero integer that will allocate more resources to the VM. By default we allocate 1 vCPU and 512MBs of RAM, enabling `V_DEV` allocates 2 vCPUs and 2048MBs of RAM. Vagrant will also attempt to sync the host `GOPATH` to `/home/vagrant/go`
  - `V_RELAY`: A 0 or non-zero integer that will set up vaquero to be deployed on a separate subnet from its booting hosts. It will also set up a dual homed `gateway` machine that will forward packets between the subnets. *The data model must be updated to reflect the new IPs / subnet. The fastest way to run with relay is using the local_dir and run the `provision_scripts/relay-setup.sh` script, run `/provision_scripts/relay-reset.sh` to bring the data model back to the start state. If you want to do it via github, you must make your own repo and update the server and agent IPs.*

By default, the only ENVIRONMENT variable set is `VS_NUM=1`.


#### a) Run Commands with Environment Vars  
  - `vagrant up`: deploys one vaquero VM in standalone mode

  - `VA_NUM=1 vagrant up`: deploys one vaquero server and one vaquero agent.

  - `VS_NUM=3 VA_NUM=3 V_RELAY=1 vagrant up`: deploys 3 vaquero servers and 3 vaquero agents with the relay.

##### *WARNING*: You must set these environment variables in your session or prepend the ENV vars to every `vagrant` command.

  For example: `VS_NUM=3 vagrant up` will stand up 3 vaquero server VMs. Running `vagrant destroy -f` will only destroy the first instance, you must run `VS_NUM=3 vagrant destroy -f` to clean up all of them. Include *every* ENV var for *every* vagrant command, even things like `vagrant ssh vs-3`.

  **Etcd check:** Once the VM(s) are booted and before running vaquero, ssh into one of your server machines. Perform a cluster health check:
  `ETCDCTL_API=2 etcdctl cluster-health`. If an error message appears, wait until all machines are live, then perform the cluster health check again.   

## 3. pull the latest docker image

`docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`


## 4. run vaquero with one of the source of truth types

We default DHCP to run in server mode. If you want to run vaquero in DHCP proxy mode, edit the configuration in `config/` and start the dnsmasq VM by running: `vagrant up dnsmasq`. This will stand up dnsmasq VM running a DHCP server that only serves IP addresses.

See the different [configurations](https://github.com/CiscoCloud/vaquero-vagrant/tree/master/config).


### Standalone mode

##### git SoT:

*You must add your personal git token into the [config](https://github.com/CiscoCloud/vaquero-vagrant/tree/master/config) for this to work.*

`docker run -v /vagrant/config/git-sot.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

##### dir SoT:

`docker run -v /vagrant/config/dir-sot.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files -v /vagrant/local:/vagrant/local --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`


### separate server and agent

1. Update data model to reflect VM IPs. Look at the site's `env.yml` and ensure the agent IP is correct. See the `vagrant VM table` below to see IPs for `vs` and `va` VMs

2. Ensure server configuration and agent configuration match the IPs of the VM's. We have provided two example configs for separate server and agent using the local dir SoT in the vagrant repo. `VS_NUM=1 VA_NUM=1`

3. Run each container in their respective mode. `server` or `agent` instead of `standalone`

##### separate server dir SoT

`docker run -v /vagrant/config/dir-sot-server.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files -v /vagrant/local:/vagrant/local --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest server --config /vaquero/config.yaml`

##### separate agent dir SoT

`docker run -v /vagrant/config/dir-sot-agent.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files -v /vagrant/local:/vagrant/local --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest agent --config /vaquero/config.yaml`


## demo lab

Vaquero provides this vagrant environment as a sandbox to work with vaquero before deployment. We provide 9 mac -> IP mappings that are free for your use / testing, the machines labeled SANDBOX would be free. We also provide two example data models, one as a [github](https://github.com/CiscoCloud/vaquero-examples/tree/vagrant) SoT and a local dir SoT, [vaquero-vagrant](https://github.com/CiscoCloud/vaquero-vagrant/tree/master/local). These define the demo machines and are a working data model to use as an example when you develop your own SoT.

### virtual env layout

#### vagrant VM table
There are `*`'s in the third space because VMs can be on the 10.10.10.0/24 or the 10.10.11.0/24 network. If no http relay is in effect all machines will be on the 10.10.10.0/24 network, if relay is active, vaquero services will be moved to 10.10.11.0/24 while booting hosts will be on 10.10.10.10/24


| Vagrant VM     | IP Address               |
|:---------------|:-------------------------|
| Relay gateway  | 10.10.10.3 & 10.10.11.3  |
| Free           | 10.10.\*.4               |
| Vaquero server | 10.10.\*.5 - 10.10.\*.7  |
| Vaquero agent  | 10.10.\*.8 - 10.10.\*.10 |


#### booting host table


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
2. You must add your personal git token into the [config](https://github.com/CiscoCloud/vaquero-docs/tree/VagrantEnv/config) for this to work.
3. Create your own github repo to contain your own data model
4. If your machine is not routable set up [ngrok and the githook as described in the README](README.html)
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

### [running the validator OR preview](validator.html)
After sshing into the vagrant VM, with the container on it. Preview will work in the same way.

Validator using a git repo
`docker run -v <SRC_CFG>:<DEST_CFG> shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest validate --config <DEST_CFG>`

Validator using a local dir
`docker run -v <SRC_DIR>:<DEST_DIR> shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest validate --sot <DEST_DIR>`
