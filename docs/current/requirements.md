<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Requirements</title>
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

# Vaquero Requirements
[Home](https://ciscocloud.github.io/vaquero-docs/) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

The Vaquero project is designed to simplify the provisioning and ongoing operations of clustered software on bare metal infrastructure.

### Use Cases:

**Actor: DevOps Engineer**

1. As a DevOps Engineer, I want to be able to manage my bare metal compute (hardware) as code.

## Requirements:

### Completed : 11/2016
1. A textual and structured representation of the cluster in a VCS -- the source of truth (SoT).
2. Validation of data within SoT -- proper structure, dump work to be performed in human-readable format. (some minimum validation of "known" asset formats?)
3. Support for netboot (iPXE, TFTP, etc.) of cluster instances.
4. Support for delivering O/S assets (kernel, ramdisk, images, cloud-config, etc.) via HTTP. (Assumes iPXE support.)
5. Management of multiple clusters of software.
6. Integration with GitHub has provider of SoT.
7. System should treat SoT as an immutable reference.
8. Management of multiple datacenters via federated architecture.
9. Relationship between SoT to cluster instances via static identifiers (MAC, UUID, others?).
11. Workflow automation to provide managed installs of cluster.
12. Workflow automation to provide managed updates of cluster.
13. Automatically provision hardware according to the SoT.
14. The ability to gate changes from SoT before applying to hardware.

### In Progress
10. Manage power state of the hardware.
15. Support incremental (multistep) cluster provisioning.
16. Provide availability in the following network conditions:
    * network partition between agent and controller
    * upgradability of agent node

### Incompplete
16. Provide availability in the following network conditions:
    * ~~outage of agent node~~


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
* Security: management of encryption keys
