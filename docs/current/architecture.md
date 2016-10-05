<head>
      <meta charset="UTF-8">
      <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Vaquero Architecture</title>
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

# Vaquero: Architecture
[Home](https://ciscocloud.github.io/vaquero-docs/)

[Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

**Last Updated**: September 2016

The Vaquero project is designed to simplify the provisioning and ongoing operations of clustered software on bare metal infrastructure. A running Vaquero system will be composed of a centralized control plane that automates provisioning of software in one or more data centers.

The goal is to provide the ability for teams to manage their infrastructure using the same tools they use for their applications (revision control, CI/CD pipeline, etc.), to and enable similar workflows including automated updates, gating, immutability, and A/B deployments. The final outcome will be a fully operational data center running heterogeneous deployments of clustered software on bare metal, with fully automated deployment and upgrades driven by a CI pipeline.

## Architecture

The diagram linked below depicts Vaquero's application architecture at a high level. All components should run as containers, but some will need various levels of privilege to perform their required functionality. As of now, Vaquero is delivered in one container for operational simplicity. Vaquero can run in multiple modes, including server, agent, and standalone (the combination of server and agent).

![](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/ppt-arch.png)

### The Datacenter Node

Each datacenter will be able to operate without an active connection to the master nodes once the active datacenter configuration has been staged to those nodes. The system is composed of multiple services, which should be operated with redundancies for availability.

#### `vaquero agent`

The `vaquero` process in `agent` mode registers itself with an upstream master and drives provisioning in a local datacenter.

1. **PXE Boot Service** - implements the necessary protocols to get a node from PXE ROM to a working Linux kernel.
  - DHCP: Has two run modes. Authoritative and Proxy
  - TFTP: Hosts the `undionly.kpxe`
2. **HTTP Server** - listens for commands from the central Vaquero server to update its assets and data model.
3. **Asset Server** - implements a file server or reverse proxy to forward requests to a CDN. This delivers unattend boot scripts, kernels, and initrds.
4. **Lifecycle Service (Future Roadmap)** - implements the necessary protocols to manage the lifecycle of a server. This can leverage O/S-based mechanisms to hardware-based systems driven by IPMI, etc.
5. **State Engine (Future Roadmap)** - implements a state tracking system to manage multi-step configurations, and provides status updates to master nodes.

### The Control Node

The overall solution will be driven by a centralized control system node that manages the process of transforming updates for our Source of Truth (SoT) into configurations that can be applied by the datacenter nodes. To perform this transformation, the system will need to process updates from the SoT, compile the changes, and stage those changes for implementation.

The structure of this data is defined [elsewhere](https://ciscocloud.github.io/vaquero-docs/docs/current/data-model-howto.html).

#### `vaquero server`

The `vaquero` application in `server` implements the control logic to push data models out to `agents`.

1. **GitHook Server** - implements a http server that processes GitHub webhooks.
2. **Client API** - implements an http client that talks to Vaquero agents.
3. **User API (Future Roadmap)** - implements functions to retrieve status, stage configurations and execute plans.


##### Endpoints:
* **/postreceive** - accepts inbound webhooks that have indicated an update has occurred in the SoT.
* **/status (Future Roadmap)** - used to inspect the current operational state of the Vaquero system and its agent nodes.
* **/prepare (Future Roadmap)** - tells the Vaquero system to stage a configuration.
* **/execute (Future Roadmap)** - performs the machine provisioning through lifecycle management, etc.

The current staging mechanism is human managed in GitHub, and it's done in the same way as it would be in a regular code repository, where, a merge into a certain branch pushes changes through vaquero. If Vaquero server receives an invalid data model from GitHub, it will not push it out to the agents.

### State Management / Coordination

There is a need in Vaquero to coordinate work between multiple instances in a reliable way. While no design has been completed around the structure of this data, we anticipate that a strongly consistent data store, such as `consul` or `etcd`, will be necessary.

## Deployment and Availability Considerations

Currently, Vaquero deploys in a single container for ease of use and deployment. Future plans are to break some of the internal Vaquero services out into their own containers.

As mentioned above, Vaquero will be delivered as several containerized services. To execute the software will require an environment that can run each of these services, and expose various ports to the network.

No explicit runtime environment is required, aside from a recent Docker engine, and sufficient capacity to run the containers required.

To achieve a highly-available system, an operator should plan to run redundant instances of the various services, and ensure they're properly connected to the coordination system.

Finally, the control node can also act as an agent if that is desired (standalone mode). This can be useful if you want to allow the control node to bootstrap agent nodes directly, or if a multi-datacenter deployment is not required.
