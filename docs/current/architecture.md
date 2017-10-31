<head>
      <meta charset="UTF-8">
      <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Vaquero Architecture</title>
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

# Vaquero: Architecture
[Home](https://ciscocloud.github.io/vaquero-docs/) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

**Last Updated**: February 2017

## Architecture

For simplicity, Vaquero is delivered as a single docker image with all of the required services available (server and agent). The same docker image can be used to start containers in both the control plane and remote agent sites.

![](https://ciscocloud.github.io/vaquero-docs/docs/current/jan17Arch.png)

### Terminology

The following terms are used throughout the documentation:

* `source of truth (SoT)`: all configuration necessary to define your infrastructure and available provisioning details (workflows, operating systems, boot configuration, unattended install scripts, and site/host-level information)

### Vaquero Server

Vaquero server is the central service that maintains the inventory and configuration workflows for provisioning your hardware. It is the service that users and Vaquero agents interact with. Vaquero server consists of the following components:

1. `User API (in progress)`: REST API for users to interact with the system and provide operational insights into booting hosts.
1. `Updater`: Responsible for updating the data models when changes are detected to a SoT; changes could come from github webhooks or from local modifications.
1. `Model API`: REST API that responds to agents looking to update their model cache; it also provides a state manifest that enables an agent to know what state its booting hosts are in.
1. `Event API`: REST API that receives events from long running services on agents.
1. `Server Controller`: Acts as an intermediary between all of the services that the Vaquero server provides.
1. `State Engine`: The brains behind vaquero; understands the data model, looks at event and task history, and ultimately makes the decision on moving provisioning hosts from one state to the next.
1. `Task Manager`: Responsible for running jobs on distributed task executors; e.g, running a container to execute a power management call to reboot a host for reprovisioning.


### Vaquero Agent

A Vaquero agent is responsible for the provisioning of a local datacenter. Many Vaquero agents can be used with a single Vaquero server. Agents are stateless by design and can be created and destroyed as needed. Agents obtain state, configuration and actions by checking in with the Vaquero server. Agents consist of the following components:

1. `Model Cache`: Handles just-in-time updates from vaquero server to serve as a cached representation of the data model; can also be used to continue operations during network outages.
1. `Agent Controller`: Acts as an intermediary between all of the services that the agent controller provides.
1. `DHCP Service`: A service that acts as either a DHCP server or DHCP proxy to provide IP and network boot details to provisioning hosts; may also work with DHCP relay services.
1. `TFTP Service`: A TFTP server that provides the initial [iPXE rom image that's responsible for chaingloading](http://ipxe.org/howto/chainloading).
1. `Asset Server`: Responsible for serving netboot assets (unattended boot scripts, kernel and initrd images, OS install files, etc); can operate as a local file server or reverse proxy to remote CDNs.
1. `Event Client`: Reports long running service events (DHCP, TFTP, HTTP) back to vaquero server.
1. `Task Executor`: Responsible for receiving container-based tasks from vaquero server and executing them on the managed hosts; vaquero leverages this for LOM management and running pre/post reboot containers to flush and validate state on a host.

### Data Model Update Workflow

1. SoT updated -- either locally or github repo
1. Updater fetches update
1. Server controller receives event and stores model model storage (local or etcd)
1. State engine computes differences between current state and new desired state from the SoT
1. State engine creates LOM tasks for related task executors to reboot hosts
1. Vaquero agent task executor obtains and runs LOM task to reboot hosts
1. Host boots and begins netboot workflow
1. Model cache and state manifest is updated via vaquero server's Model API
1. Events are reported via vaquero server's Event API
1. State engine observes event and task status and will act until desired state is reached

## HA Vaquero

![](https://ciscocloud.github.io/vaquero-docs/docs/current/jan17HA.png)

The diagram above depicts a production deployment of Vaquero. Vaquero implements its own leader election, and also contains a readiness probe to integrate with kubernetes deployments.

### Running Vaquero with Internal HA

Vaquero implements leader election using Etcd's [built in leader election](https://godoc.org/github.com/coreos/etcd/clientv3/concurrency). Our procedure works by giving every vaquero server a unique ID. All running servers campaign on the same Etcd "leader" key, and attempt to put their own unique IDs as the "leader" value. One server will successfully become leader and serve as a fully-functional vaquero server, and the rest will continue to passively campaign. Should one of the vaquero servers exit, error out, or power off, another campaigning server will take on the role of leader within the etcd TTL of 1 second.

*Note*: Once a vaquero server errors out or temporarily loses contact with etcd, it is no longer permitted to continue campaigning. We expect a vaquero server to be deployed by a container orchestration system (eg. Kubernetes, Docker Swarm, Systemd) that would restart a server if it shut down. See the [outage document](outage.html) to see how Vaquero handles failures.

Ensure you have toggled the `HA` configuration flag to `true` and that your etcd cluster is properly configured and healthy before deploying HA vaquero servers. 

### HA and Kubernetes

Vaquero's readiness probe is baked into its leader election procedure. We expose a `/ready` endpoint via the vaquero UserAPI (default= `500`, not ready), and when a server becomes the elected leader, we write a `200` (ready) to the UserAPI server. This tells kubernetes that this server is the leader, and to direct traffic towards that server only.

*Note*: Currently our `/live` (liveliness probe) endpoint is hardcoded to `200` as long as the vaquero server is up-- whether it is the active leader or passively campaigning. This may change in the future when the liveliness probe is developed further.

Further, with Kubernetes we recommend deploying two vaquero agents per broadcast domain, for operational safety. See the [README](README.html) for details on production deployments, considerations, and requirements.
