# Vaquero

The Vaquero project is designed to simplify the provisioning and ongoing operations of clustered software on bare metal infrastructure. A running system will be composed of a centralized control plane that automates provisioning of software in one or more datacenters.

The goal is to provide the ability for teams to manage their infrastructure using the same tools they use for their applications (revision control, CI/CD pipeline, etc.), and enable similar workflows including automated updates, gating, immutability, A/B deployments, etc. The final outcome will be a fully operational datacenter running heterogeneous deployments of clustered software on bare metal with fully automated deployment and upgrades driven by a CI pipeline.

## Architecture

The diagram below shows a high-level view of the overall application architecture. All components should run as containers, but some will need various levels of privilege to perform their required functionality.

![Model View Controller](architecture.png)

### The Datacenter Node

Each datacenter will be able to operate without an active connection to the master nodes once the active datacenter configuration has been staged to those nodes. The system is composed of multiple services which should be operated with redundancies for availability.

#### `vaquero agent`

The `vaquero` process in `agent` mode registers itself with an upstream master and drives provisioning in a local datacenter.

1. **PXE Boot Service** -- implements the necessary protocols to get a node from PXE ROM to a working Linux kernel.
2. **Lifecycle Service** -- implements the necessary protocols to manage the lifecycle of a server. This can leverage O/S-based mechanisms to hardware-based systems driven by IPMI, etc.
3. **State Engine** -- implements a state tracking system to manage multi-step configurations, and provide status updates to master nodes.

The agent will have a built-in HTTP server that will be used for API endpoints, as well as asset delivery. The assets delivered can be provided through multiple mechanisms based on configuration, including potentially being cached (uploaded) locally, or passed through from other systems (i.e. CDN).

Some endpoints will be passed through directly to internal services, but others will be terminated by the agent (more details in [API documentation](api.md)):

* **/assets** - static assets required to boot client nodes.
* **/state** - mechanism for client nodes to report state (via API).
* **/status** - used to inspect current operational state of this agent, and its client nodes.

CoreOS Bare Metal has the following endpoints documented:

* [HTTP API](https://github.com/coreos/coreos-baremetal/blob/master/Documentation/api.md)
* [gRPC API](https://godoc.org/github.com/coreos/coreos-baremetal/bootcfg/client)

### The Control Node

The overall solution will be driven by a centralized control system node that manage the process of transforming updates for our Source of Truth (SoT) into configurations that can be applied by the datacenter nodes. To perform this transformation, the system will need to process updates from the SoT, compile the changes, and stage those changes for implementation.

The structure of this data is defined [elsewhere](env-data-structure.md).

#### `vaquero server`

The `vaquero` application in `server` implements a simple HTTP-based API that manages the overall workflow. To this end a few endpoints have been planned (these will be further details in the [API documentation](api.md)):

* **/postreceive** - accepts inbound webhooks indicated an update has occurred in the SoT.
* **/status** - used to inspect current operational state of the Vaquero system, and agent nodes.
* **/prepare** - tells Vaquero system to stage a configuration.
* **/execute** - performs the machine provisioning through lifecycle management, etc.

### State Management / Coordination

There is a need in Vaquero to coordinate work between multiple instances in a reliable way. While no design has been completed around the structure of this data, we anticipate that a strongly consistent data store, such as `consul` or `etcd`, will be necessary.

## Deployment and Availability Considerations

As mentioned above, Vaquero will be delivered as several containerized services. To execute the software will require an environment that can run each of these services, and expose various ports to the network. (needs doc)

No explicit runtime environment is required, aside from a recent Docker engine, and sufficient capacity to run the containers required.

To achieve a highly-available system, an operator should plan to run redundant instances of the various services, and ensure they're properly connected to the coordination system. (needs docs)

Finally, the control node can also act as an agent if that is desired. This can be useful to allow the control node to bootstrap agent nodes directly, or if a multi-datacenter deployment is not required.
