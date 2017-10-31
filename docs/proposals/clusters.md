# Abstract

In the current Data Model structure, all site configuration and inventory is maintained under a single repository. Additionally, all inventory in a single site is treated as a heterogeneous pool. In practice, a physical location (site) will often have multiple collections of machines (clusters) that run on similar configurations and are physically adjacent, but are otherwise unrelated to one another. This poses a few problems for achieving national scalability:

1) Without the ability to logically separate hosts in a single site, this would require the deployment of additional agents at a given location. Due to limited resources (ex: agents are being run on an Arista switch), only a limited number of agents can be deployed to maintain these adjacent clusters, making multiple agents per location infeasible. 

2) Clusters may need to be individually migrated from one version of a configuration to another. ClusterA may be used to stage recent configuration changes before ClusterB in the same site is reconfigured. Additionally, individual clusters may share much of the same site-specific configuration, but require additional configuration/metadata specific to that cluster of machines.

To eliminate these issues, this proposal outlines the redesign of the current data model to allow for the grouping of hosts within a single site, and provides a configuration layout to allow host groups to utilize different configuration versions.

# Quick Definitions

For clarity.

Configuration: all workflows, boots, OSes, assets defined in the data model. Essentially every document in the current data model not under the `sites/` directory.

Inventory: all hosts defined in a particular site. Currently gained from all files under `sites/` that are not `env.yml`.

Site: The highest level of organization for metadata/inventory. Usually refers to a single physical deployment of hosts.

Cluster: A subset of site hosts that runs under a specific configuration and does not have depedencies with other hosts outside of it's subset.


# Host Clusters

## Requirements

- Logically separate hosts into clusters within a single site
- Groups are independent w.r.t. rollout policy/workflow dependency

## Design

The current logical layout for a data model is:

```
├── assets
│   └── Config files, templates
├── boot
│   └── Pair configs + OSes, and metadata
├── os
│   └── OS kernel, initrd, cmdline information
├── sites
│   └── site-name
│       ├── env.yml <- Specifies agent configurations, site-wide metadata, subnet information
│       └── inventory.yml <- Host definitions deliminated as individual YAML documents 
└── workflows
    └── Chain multiple boots together, inter-workflow dependencies and rollout policy
```

In this layout, all hosts are declared in a homogenous pool, a site's "inventory". An example `inventory.yml`: 

```
---
name: host1
interfaces:
  - type: physical
    subnet: subnet1
    mac: 00:00:00:00:00:01
    ipv4: 127.0.0.1
metadata:
    mstr: etcd1
workflow: coreos-cloudconfig
---
name: host2
interfaces:
  - type: physical
    subnet: vagrant1
    bmc:
      type: ssh
      username: core
      keypath: /secrets/id_rsa
    mac: 00:00:00:00:00:02
    ipv4: 127.0.0.2
metadata:
    mstr: etcd2
workflow: coreos-ignition
---
name: host3
interfaces:
  - type: physical
    subnet: vagrant1
    mac: 00:00:00:00:00:03
    ipv4: 127.0.0.3
metadata:
    mstr: etcd3
    random: data
workflow: something-else
```

To accomodate logically separated pools of hosts, multiple inventory files will be specified, with each inventory file providing the hosts that belong to a single cluster in the same format shown above:

```
├── sites
│   └── site-name
│       ├── env.yml <- Specifies agent configurations, site-wide metadata, subnet information
│       ├── cluster-one.yml <- All machines associated with cluster-one
│       └── cluster-two.yml <- All machines associated with cluster-two 
```

Additionally, each cluster inventory file should be proceeded with a document containing metadata specific to that collection of machines:

```
---
# Cluster metadata
metadata:
  mstr: etcd-mstr
  http-proxy: 127.0.0.10
---
# Host 1
---
# Host 2
---
# etc...
```

The metadata here should be merged with site (env) metadata, with cluster metadata taking precedence in the event of a key collision. In this way, env metadata serves as a global "default" metadata, which may be individually overwritten by cluster metadata.


## Work Scope

This update will require changes to the Data Model definitions, parsing process, and state engine logic. All of these currently assume all inventory will be collected in one homogenous group.

## Estimated Development Time (SWAG)

Medium complexity. Approx. one month with two developers for implementation, testing, and delivery.



# Separated Configuration/Inventory

After hosts have been separated into clusters, we consider the process for separating the inventory from the defined configurations. The goal is to contain all inventory, cluster, and site information in one location, and maintain workflow and associated configurations in a separate location.

## Requirements

- Provide per-cluster info for linking to remote configuration
  - Github configuration for pulling from a remote repository
  - Local directory configuration for referencing on-disk configs
- Clusters contain metadata that augments site metadata

## Design

The current logical layout for a data model is:

```
├── assets
│   └── Config files, templates
├── boot
│   └── Pair configs + OSes, and metadata
├── os
│   └── OS kernel, initrd, cmdline information
├── sites
│   └── site-name
│       ├── env.yml <- Specifies agent configurations, site-wide metadata, subnet information
│       └── inventory.yml <- Host definitions deliminated as individual YAML documents 
└── workflows
    └── Chain multiple boots together, inter-workflow dependencies and rollout policy
```

In the current layout, all site inventory and metadata is stored under `sites`. Everything else is configuration.


Separating the data model will place all site inventory and metadata into one location, and all configuration into another:

`Location 1: Inventory`
```
└── sites
    ├── site-one
    │   ├── env.yml <- Specifies agent configurations, site-wide metadata, subnet information
    │   ├── cluster-one.yml <- Host definitions deliminated as individual YAML documents 
    │   └── cluster-two.yml <- Host definitions deliminated as individual YAML documents 
    └── site-two
        ├── env.yml <- Specifies agent configurations, site-wide metadata, subnet information
        └── inventory.yml <- Host definitions deliminated as individual YAML documents 
```

`Location 2: Configuration`
```
├── assets
│   └── Config files, templates
├── boot
│   └── Pair configs + OSes, and metadata
├── os
│   └── OS kernel, initrd, cmdline information
└── workflows
    └── Chain multiple boots together, inter-workflow dependencies and rollout policy
```

Additionally, each inventory file will specify a configuration document with the details required for fetching the desired configuration from a remote location. For example: 

`site-one/cluster-one.yml`
```
---
# cluster config document
config:
  git_url: "https://github.com/CiscoCloud/vaquero-examples"
  git_token: 7d320fcbef36f52bbe63e0428a24d5aad4bcc72d
  git_tag: v0.1
metadata:
  ...
---
# host 1
---
# host 2
---
# etc...
```

The details of the config document are left open ended for this proposal. At a minimum, configuration must provide adequate information for Vaquero server to securely pull from a git repository.

Vaquero should be configured only to receive webhooks from the site/inventory repository. Configurations should be referenced via commit-ish or tag, which may be updated to inform Vaquero that a new configuration/version should be imported for a particular cluster of machines.

## Estimated Development Time (SWAG)

Medium-heavy work load. Approx. two months with two developers for implementation, testing, and delivery.
