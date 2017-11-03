---
layout: page

---
<div align="center" markdown="1">

  <img src="{{ site.url }}/img/cow.png" alt="Drawing" style="width: 200px;"/>

  [Home]({{ site.url }}) | [Dev Repo](https://github.com/CiscoCloud/vaquero) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master) | [Project Requirements](requirements.html) | [Issue Tracking](https://waffle.io/CiscoCloud/vaquero)

</div>
<h1></h1>
Vaquero is designed to simplify the provisioning and repurposing of your bare metal infrastructure. Vaquero is driven by user defined templates to network boot machines. We leverage iPXE and support cloud-config, ignition, kickstart, and untyped unattend boot scripts.


# Use Cases
Let's walk through a couple of typical scenarios that Vaquero can be used for...

## Building Out a New Datacenter

You are building out a new datacenter and you have purchased some new servers. Before the hardware even arrives you typically get all of the hardware specifications. With that you can easily pre-configure your site configuration in Vaquero based on the hardware specs. When your machines arrive simply rack and stack them as you normally would and Vaquero will do the rest, from powering them on (if you choose to use the power managment option) to laying down the OS you specified in the Vaquero workflow.

## Repurpose Existing Hardware

Suppose you have a rack of gear that you want to repurpose for a different project. Maybe your new project is running on a new OS or has different hardware configuration needs. With vaquero, this migration is as simple as updating the config files with the new bits and Vaquero will take care of the rest.

# Features

**Operations / Deployment**:

- Operational simplicity: Vaquero is deployed from a single container that can run in server, agent, and standalone modes.
- Centralized control plane: Vaquero server is designed for high availability and linear scalability
- Site local vaquero agents are stateless and can be created and destroyed at will.
- Safe to run in a multi-tenant environment: Vaquero DHCP will only respond to known hosts in its data model.
- Vaquero agent implements a DHCP server that can run in proxy mode or full DHCP mode, with support for DHCP relay.
- Support for Vaquero agent multihoming.
- Built-in authoritative detector notifies operator if an "authoritative" DHCP server is in the same broadcast domain.
- Vaquero servers act as state machines, and are able to migrate the desired host state within the data model over to the physical host
- Vaquero servers able to handle failure states in boot process, will retry, halt, or revert based on user policy.
- High availability for Vaquero servers - seamless leader election via CoreOS Etcd
- Kubernetes integration for HA via readiness probe

**Booting**

- Hardware-agnostic bare metal management with pxe and IPXE-based network booting.
- Support and validation for kickstart, cloud-config, ignition, and custom unattended boot scripts
- Vaquero agent support for serving local files over http, or for acting as a reverse proxy for a CDN
- Supports BIOS and uEFI PXE booting

**[Tooling](tools.html)**

- Command-line migrate tool for transferring stored information of SoTs and sites
- Command-line preview tool for iPXE/unattended boot scripts, before sending to hosts
- Command-line validator for checking your data model before you push it through Vaquero
- Robust Vagrant environment to test single-node deployments, or Vaquero server cluster and multiple agent deployments.

# Try it
The only requirement for running Vaquero is [Docker](https://www.docker.com/).

See the [Getting Started]({{ site.url }}/docs/current/getting-started.html) page for details on deploying Vaquero in virtualbox.
