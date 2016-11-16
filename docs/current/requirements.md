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

## System Requirements

* System will provide support for customized agent and server configurations, as well as support for standalone mode (both agent and server in one container)
* System will implement REST-based APIs for working w/external systems (i.e. GitHub webhook).
* System will use REST-based APIs for coordination between different nodes.
* System will provide APIs to allow inspection system state.
* System will provide detailed logs of operations.
* Internal APIs will be protected via an authentication mechanism (i.e. bearer token).
* System will provide demos and examples for new vaquero users


## Project Tasks (as of 11/16/2016):

### Completed:
1. A textual and structured representation of the cluster in a VCS -- the source of truth (SoT).
2. Validation of data within SoT -- proper structure, dump work to be performed in human-readable format. (some minimum validation of "known" asset formats?)
3. Support for netboot (iPXE, TFTP, etc.) of cluster instances.
4. Support for delivering O/S assets (kernel, ramdisk, images, cloud-config, etc.) via HTTP. (Assumes iPXE support.)
5. Management of multiple clusters of software.
6. Integration with GitHub has provider of SoT.
7. System should treat SoT as an immutable reference.
8. Management of multiple datacenters via federated architecture.
9. Relationship between SoT to cluster instances via static identifiers (MAC, UUID, others?).
10. Manage power state of the hardware.
11. Workflow automation to provide managed installs of cluster.
12. Workflow automation to provide managed updates of cluster.
13. Automatically provision hardware according to the SoT.
14. The ability to gate changes from SoT before applying to hardware.
15. Support incremental (multistep) cluster provisioning.
16. Set up initial integration between vaquero and coreOS etcd (key-value store)
17. Bulked up the command line interface to support flag overrides and descriptions
18. Enabled DHCP support for provisioning on multiple subnets
19. Snippets support (go templating) to allow unattended configuration files to follow the same basic format   

### In Progress:
1. Develop a shared state engine between vaquero servers for persistent key-value storage via etcd
2. Develop an internal API that allows for communication between server and agent
3. Implement a task queue using the internal API, in which vaquero server sends an agent tasks to complete
4. Develop a user-facing API
5. Build a capability that allows agents to securely self-register with vaquero server
6. Examples and documentation for snippets
7. API documentation for user and internal APIs

### Not Started:
1. Improved concurrency and channel handling
2. Full transition to updated data model format
3. Implementation of workflows
4. Foreman-to-vaquero template converter
5. Lifecycle management to handle data model upgrades
6. Config file generator
7. Inventory state tracking for client nodes

---------------

### Non-requirements:

* Have semantic understanding of installed software.
* Dynamic system inventory.
* Pre-built user interface.

### Out-of-Scope:

* Security: integration w/role base systems
* Security: management of user credentials
* Security: management of assymetric encryption keys
