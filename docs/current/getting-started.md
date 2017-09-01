---
layout: page
page.title: Getting Started
---
# Getting started

[Home]({{ site.url }}) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

## Prerequisites

This getting started guide provides a simple Vagrant-based environment to run Vaquero in "standalone mode" and requires the following prerequisites before moving forward:

1. [Latest Vagrant](https://www.vagrantup.com/)
2. [VirtualBox 5.1.x (v5.2.x is not supported by Vagrant at this time)](https://www.virtualbox.org/wiki/Download_Old_Builds_5_1)
3. [Install VirtualBox Extension Pack to match your version of VirtualBox](https://www.virtualbox.org/wiki/Download_Old_Builds_5_1) Adds functionality to PXE boot for Intel cards
4. Access to [vaquero docker repository](
https://hub.docker.com/r/thecsikos/vaquero/); this is currently a private docker repository

## Try it out locally

### Clone the vaquero-vagrant repository

The vaquero-vagrant repository contains all the bits necessary to get a small Vaquero environment running on your local machine using VMs:

```
git clone https://github.com/CiscoCloud/vaquero-vagrant.git
cd vaquero-vagrant
```

### Start it up and jump into the VM

The provided Vagrantfile allows for various options to override the default configuration, but we'll use the defaults for now. For more information on the additional options, please take a look at the Vagrantfile.

```
vagrant up
```

now that you have the VM running, SSH into the VM:

```
vagrant ssh vs-1
```

currently, the Vaquero docker image is protected and you'll need access to the docker hub repository. Use docker to login with your credentials:

```
# NOTE: this command will prompt you for your credentials
docker login docker.io
```

next, pull the latest Vaquero docker image:

```
docker pull thecsikos/vaquero:latest
```

and finally, start Vaquero in standalone mode:

```
docker run \
  -v /vagrant/config/dir-sot.yaml:/vaquero/config.yaml \
  -v /var/vaquero/files:/var/vaquero/files \
  -v /vagrant/local:/vagrant/local \
  -v /vagrant/provision_files/secret:/vaquero/secret \
  --net="host" \
  -e VAQUERO_SHARED_SECRET="<secret>" \
  -e VAQUERO_SERVER_SECRET="<secret>" \
  -e VAQUERO_SITE_ID="test-site" \
  -e VAQUERO_AGENT_ID="test-agent" \
  thecsikos/vaquero:latest \
  standalone --config /vaquero/config.yaml
```

You now have both a Vaquero server and agent (standalone mode) running in your vs-1 VM.

```
+----------------------------------+
| vs-1                             |
|  +------------+    +----------+  |
|  | vq server  |    |vq agent  |  |
|  |            |    |          |  |
|  |            |<---|          |  |
|  |            |    |          |  |
|  +------------+    +----------+  |
+----------------------------------+
```

### Start additional VMs that Vaquero will provision

Now we can use Vaquero to provision an additional VM running CentOS. Before executing the command below, you'll want to open the VirtualBox manager so you'll be able to see the new VM (named boot-0). When it does come into view, you can then double click on the boot-0 VM to open its console window to watch the pxe boot happen. You can also follow along with the Vaquero agent log in your vs-1 VM.

**NOTE: This step simulates the automatic power management features of Vaquero by using a shell script to manually issue VBoxManage commands to configure and "power on" additional VMs for Vaquero to provision. In a baremetal environment, Vaquero would automatically power on servers and provision them accordingly.**

```
# NOTE: run this in a new shell outside of the vs-1 VM
./create_cluster/cluster.sh -d centos
```

```
+--------------------------------+              +----------+
| vs-1                           |              | boot-0   |
|  +------------+  +----------+  |     PXE      |          |
|  | vq server  |  |vq agent  |<----------------|          |
|  |            |  |          |  |              |          |
|  +------------+  +----------+  |              |          |
+--------------------------------+              +----------+
```

**NOTE: If you get an error on the console of boot-0, "No bootable medium" it's a good indication that the VirtualBox Extension Pack was not installed (in the prerequisites above). You will need to install that, completely remove that VM (boot-0), and then run the cluster.sh command again.**

### Finish up

When you're done with the Vaquero and boot VMs that have been started with the steps above, do the following the clean up your environment:

In the vs-1 VM:
```
# Kill the running Vaquero server/agent
ctrl+c

# Exit the VM
ctrl+d

# Destroy the VM
vagrant destroy vs-1
```

To cleanup the boot-0 VM, right-click its entry in the VirtualBox manager and find the Power Off action under the Close menu; you can then right-click and remove the VM.

## Next steps

At this point, you've successfully run Vaquero and provisioned a CentOS machine using VMs in your local environment. In "standalone mode", the Vaquero server and agent run together in a single VM (vs-1). In a production setting, it is more suitable to have these services split out. Although it is possible to demonstrate that with separate VMs it is out of the scope for this getting started guide.

[Setting up Vaquero on bare metal]({{ site.url }}/docs/current/bare-metal.html)
