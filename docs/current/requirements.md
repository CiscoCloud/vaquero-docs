<link rel="stylesheet" type="text/css" href="../doc.css"">


# Vaquero Requirements

The Vaquero project is designed to simplify the provisioning and ongoing operations of clustered software on bare metal infrastructure.

Use case(s):

Actor: DevOps Engineer

1. As a DevOps Engineer, I want to be able to manage my bare metal compute (hardware) as code.

## Requirements:

1. A textual and structured representation of the cluster in a VCS -- the source of truth (SoT).
2. Validation of data within SoT -- proper structure, dump work to be performed in human-readable format. (some minimum validation of "known" asset formats?)
3. Automatically provision hardware according to the SoT.
  1. Support for netboot (PXE, TFTP, etc.) of cluster instances.
  2. Support for delivering O/S assets (kernel, ramdisk, images, cloud-config, etc.) via HTTP. (Assumes iPXE support.)
4. Management of multiple clusters of software.
5. Integration with GitHub has provider of SoT.
6. Management of multiple datacenters via federated architecture.
7. System should treat SoT as an immutable reference.
8. Relationship between SoT to cluster instances via static identifiers (MAC, UUID, others?).
9. Manage power state of the hardware.
10. Workflow automation to provide managed installs of cluster.
11. Workflow automation to provide managed updates of cluster.
12. The ability to gate changes from SoT before applying to hardware.
13. Support incremental (multistep) cluster provisioning.
14. Provide availability in the following network conditions:
    * network partition between agent and controller
    * ~~outage of agent node (and upgrade of agent node)~~

## Non-requirements:

* Have semantic understanding of installed software.
* Dynamic system inventory.
* Pre-built user interface.

## Implementation details:

* System will implement REST-based APIs for working w/external systems (i.e. GitHub webhook).
* System will use REST-based APIs for coordination between different nodes.
* System will provide APIs to allow inspection system state.
* System will provide detailed logs of operations.
* Internal APIs will be protected via an authentication mechanism (i.e. bearer token).

## Out-of-Scope:

* Security: integration w/role base systems
* Security: management of user credentials
* Security: management of assymetric encryption keys
