<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Requirements</title>
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

# Vaquero Requirements
[Home](https://ciscocloud.github.io/vaquero-docs/) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

The Vaquero project is designed to simplify the provisioning and ongoing operations of clustered software on bare metal infrastructure.

### Use Cases:

**Actor: DevOps Engineer**

1. As a DevOps Engineer, I want to be able to manage my bare metal compute (hardware) as code.

## Requirements:

### Completed (as of Feb. 2017)
1. A textual and structured representation of the cluster in a VCS -- the source of truth (SoT).
2. Validation of data within SoT -- proper structure, dump work to be performed in human-readable format. (some minimum validation of "known" asset formats?)
3. Support for netboot (iPXE, TFTP, etc.) of cluster instances.
4. Support for delivering O/S assets (kernel, ramdisk, images, cloud-config, etc.) via HTTP. (Assumes iPXE support.)
5. Management of multiple clusters of software.
6. Integration with GitHub has provider of SoT.
7. System should treat SoT as an immutable reference.
8. Management of multiple datacenters via federated architecture.
9. Relationship between SoT to cluster instances via static identifiers (MAC, UUID, others?).
10. Workflow automation to provide managed installs of cluster.
11. Workflow automation to provide managed updates of cluster.
12. Automatically provision hardware according to the SoT.
13. The ability to gate changes from SoT before applying to hardware.
14. The ability to deploy separate instances of servers and agents and documentation on how to do it.
15. Document HA scenarios for servers and new deployment requirements for persistent storage to back server cluster.
16. HTTPS communication is a must for API's between servers and agents.
17. DHCP options to be more robust in handling NTP & DNS assignment.
18. Vaquero standalone mode to manage internal labs.
19. Provide availability in the following network conditions:
    * network partition between agent and controller
    * upgradability of agent node
20. Support incremental (multistep) cluster provisioning.
21. Deploy a first build of all software clusters in lab.
22. Separated Vaquero Server and Vaquero Agent to manage internal labs.
23. Successfully guide multi-stage deployments managed by state machine on vaquero server(s).
24. High availability Vaquero servers via Etcd
25. Readiness probe for Kubernetes deployments and high availability
26. Manage power state of the hardware
27. Upgrade workflow definitions to run pluggable pre-reboot and post-reboot jobs.
28. A policy engine that will ensure operational safety when updating a site, such as valid reboot times, minimum machines to be operational, dependency tracking and validation.
29. A pluggable framework to enable pre-shutdown actions to be taken on a single host to flush its workload before cutting the power
30. A pluggable framework to enable post-boot actions to validate a successful deployment of a single host.

### On the Roadmap

1. Provide state transition details and host status to provide operational insights (via userAPI)
2. Liveness probe for Kubernetes

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
