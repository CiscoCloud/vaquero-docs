---
layout: page
page.title: Baremetal
---
# Getting Started on Bare Metal

[Home]({{ site.url }}) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

## Prerequisites

This getting started guide focuses on getting up and running in a bare metal environment. Like the VM-based getting started guide, we'll again configure and run vaquero in "standalone mode" to reduce the overall footprint of the environment.

To continue with the guide, please have the following available:

1. One bare metal machine for running vaquero in standalone mode. See the next section on appropriate configuration.
2. A second bare metal machine which must support PXE booting and IPMI (for power management)
2. Both machines must be on the same network, and the network should be free of any existing DHCP service
3. Access to [vaquero docker repository](
https://hub.docker.com/r/thecsikos/vaquero/); this is currently a private docker repository

## Configure the vaquero server/agent

Similar to the VM-based approach, we'll configure the first server to run vaquero in "standalone mode" using Docker. For our purposes, we're running RHEL 7.4, but you should be able to use any OS that docker supports.

Packages required to continue:

* docker
* git

### Get the vaquero image

Login to docker hub using credentials that have access to the vaquero docker repo:

```
# NOTE: this command will prompt you for your credentials
docker login docker.io
```

and pull the latest vaquero docker image:

```
docker pull thecsikos/vaquero:latest
```

## Prepare vaquero source of truth (SoT) directory

For our purposes, we'll be using the local directory mode for the vaquero server's SoT. You can do the same using a github repo, however you will need to make sure your server is routable to the internet and available to receive webhooks which is outside the scope of this getting started guide.

### Initial directory structure

First, create the initial directory structure where all configuration will live:

```
mkdir -p /var/vaquero-demo/{files,save}
```

Next, we'll make use of the vaquero-vagrant repo to help bootstrap our SoT:

```
git clone https://github.com/CiscoCloud/vaquero-vagrant.git /tmp/vaquero-vagrant

cp -R /tmp/vaquero-vagrant/local /var/vaquero-demo/
cp -R /tmp/vaquero-vagrant/provision_files/secret /var/vaquero-demo/
```

### CentOS pxe boot files

Vaquero agents are responsible for netbooting hosts defined for the agent's site. As such, to properly netboot a particular OS requires that the agent be able to serve up the required files to do so. In our case, we're provisioning a host with CentOS which requires the following:

* kernel image for pxe boot
* initrd image for pxe boot
* kickstart script for unattended install
* any additional files required by the kickstart script

The kickstart file is already provided in the `vaquero-vagrant` SoT we copied above. You can find it at `/var/vaquero-demo/local/assets/kickstart/centos.yml` and if you take a look, you'll notice that it's a pretty vanilla kickstart that's really only useful for our demo environment. You would most certainly want to change (or remove) the default root password along with mirroring the upstream CentOS installation files for faster installs.

For our purposes, we'll only need to grab the kernel and initrd files from CentOS and put them in our `files` directory.

```
cd /var/vaquero-demo/files
curl -o centos7.vmlinuz http://128.200.84.11/centos/7/os/x86_64/images/pxeboot/vmlinuz
curl -o centos7_initrd.img http://128.200.84.11/centos/7/os/x86_64/images/pxeboot/initrd.img
```

### Configure your site

This step is critical in making sure your site's hosts and agents are properly configured and must match you specific environment.

First, head over to the site directory:

```
cd /var/vaquero-demo/local/sites/test-site/
```

and modify the `env.yml` file to look like:

```
---
name: test site
id: test-site
subnets:
  - id: primary
    cidr: 10.10.10.0/24
    gateway: 10.10.10.1
    dns:
    - 10.10.10.10
agents:
- name: test-agent
  asset_server:
    addr: 10.10.10.20
    port: 24602
    base_dir: /vaquero/files
    scheme: http
  dhcp_mode: server
  save_path: /vaquero/save
```

**NOTE: the above yaml file must be configured to your specific bare metal environment. Please modify the following values:**

* `subnets[0].cidr`: set to your subnet's CIDR
* `subnets[0].gateway`: set to your subnet's gateway
* `subnets[0].dns`: a list of DNS servers for your environment
* `agents[0].asset_server.addr`: this server's IP address

### Configure your site's hosts

This step is equally critical in making sure your site's hosts are defined properly. If you don't provide the correct information, then vaquero will not be able to provision them.

First, head over to the site directory:

```
cd /var/vaquero-demo/local/sites/test-site/
```

and modify the `inventory.yml` file to look like:

```
---
name: test-01
interfaces:
  - type: physical
    subnet: primary
    mac: de:ad:be:ef:00:01
    ipv4: 10.10.10.30
  - type: bmc
    subnet: primary
    mac: de:ad:be:ef:10:01
    ipv4: 10.20.10.30
    bmc:
      type: ipmi
      username: user
      password: Password!
workflow: centos
```

**NOTE: the above yaml file must be configured for the specific hosts you wish to provision with vaquero. Please modify the following values:**

* `interfaces[0].mac`: the mac address of the nic used for pxe booting
* `interfaces[0].ipv4`: the IP address to assign when pxe booting
* `interfaces[1].mac`: the mac address of the BMC to use for IPMI
* `interfaces[1].ipv4`: the IP address of the BMC to use for IPMI
* `interfaces[1].bmc.username`: the username for authenticating with IPMI
* `interfaces[1].bmc.password`: the password for authenticating with IPMI

### Vaquero standalone config file

When running vaquero in any mode, it requires a config file when starting up. In our case, we'll be running in standalone mode, which requires the configuration for both a server and agent.

**NOTE**: we'll be running vaquero in docker, so the paths in this file will be relative to the docker volumes we mount in. It's pretty easy to confuse the host and container paths :)

Create a `/var/vaquero-demo/standalone-config.yml` and modify to look like:

```
---
ServerAPI:
  Addr: 10.10.10.20
  Port: 24601
  PrivateKey: /vaquero/secret/server.key
  PublicKey: /vaquero/secret/server.pem
ServerClient:
  Addr: 10.10.10.20
  Port: 24601
  InsecureSkipVerify: True
SavePath: /vaquero/save
LocalDir:
  PollInterval: 10
SoT:
- Local:
    ID: vaquero-demo
    Root: /vaquero/local
Log:
  Level: debug
  Location: stdout
  Type: text
```

**NOTE: the above yaml file must be configured for your specific environment. Please modify the following values:**

* `ServerAPI.Addr`: the local IP of the vaquero server
* `ServerClient.Addr`: the local IP of the vaquero agent (this should be the same as ServerAPI.Addr since we'll be running in standalone mode)

### Simple shell script to help us start vaquero

Below is a shell script to make it easy to run vaquero in standalone mode with all that we've configured above. It will run a docker container in the foreground so we can see all the logs happening. When we're done with the container, a simple CTRL+C will exit and clean up the vaquero container for us.

Create a `/var/vaquero-demo/run-standalone.sh` file and modify to look like:

```
#!/bin/bash

docker run -it --rm \
  -v /var/vaquero-demo/standalone-config.yml:/vaquero/config.yml \
  -v /var/vaquero-demo/files:/vaquero/files \
  -v /var/vaquero-demo/local:/vaquero/local \
  -v /var/vaquero-demo/secret:/vaquero/secret \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e VAQUERO_SHARED_SECRET=secret \
  -e VAQUERO_SERVER_SECRET=secret \
  -e VAQUERO_SITE_ID=test-site \
  -e VAQUERO_AGENT_ID=test-agent \
  --net=host \
  --privileged \
  thecsikos/vaquero:latest \
  standalone --config /vaquero/config.yml
```

Change the file mode:

```
chmod 755 /var/vaquero-demo/run-standalone.sh
```

### Preflight checklist

Prior to starting vaquero, it's very useful to bring up the consoles for the hosts vaquero will be provisioning. This way, we can see what's happening in the vaquero log and on the host machines to get a better view of the overall process. The specifics on console access is entirely dependent on the servers you're using, but it's usually as simple as pointing your browser to the same address you used in the IPMI configuration above and signing in.

### Start vaquero

Use the helper script from above to start vaquero in standalone mode:

```
cd /var/vaquero-demo
./run-standalone.sh
```

You now have both a Vaquero server and agent (standalone mode) running in your first bare metal server:

```
+----------------------------------+
| server0                          |
|  +------------+    +----------+  |
|  | vq server  |    |vq agent  |  |
|  |            |    |          |  |
|  |            |<---|          |  |
|  |            |    |          |  |
|  +------------+    +----------+  |
+----------------------------------+
```

The host defined in your site's inventory.yml file will now be automatically provisioned. Vaquero will use the provided IPMI information to enable PXE boot, restart the server, and netboot the host using the CentOS workflow defined in your SoT.

```
+--------------------------------+              +----------+
| server0                        |              | server1  |
|  +------------+  +----------+  |     PXE      |          |
|  | vq server  |  |vq agent  |<----------------|  CentOS  |
|  |            |  |          |  |              |          |
|  +------------+  +----------+  |              |          |
+--------------------------------+              +----------+
```

### Finish up

When you're done with the Vaquero and boot servers, you may power them off or continue to provision additional machines by updating the site's inventory with more bare metal hosts.

## Next steps

At this point, you've successfully run Vaquero and provisioned a bare metal machine with CentOS. In "standalone mode", the Vaquero server and agent run together in a docker container running a single machine. In a production setting, it is more suitable to run the vaquero server on a centralized machine with multiple vaquero agents running in different locations/networks to manage multiple groups of hosts as desired.

For more information on running multiple sites/agents with a centralized vaquero server, please visit the [vaquero docs]({{ site.url }}).

