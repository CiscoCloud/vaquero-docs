[Key Concepts](#key-concepts)

[Vocabulary](#vocabulary)

[Where things go](#where-things-go)

[Rough Workflow](#rough-workflow)

[Serving files](#serving-files)

[Metadata and Templating](#metadata-and-templating)

[Translation to iPXE](#translation-to-ipxe)

[Schemas](#schemas)


# Vaquero Data Model and YOU

The Vaquero data model is meant to be a declarative representation of the state of your datacenter. You specify the state you want your baremetal to be in, and Vaquero takes the steps to get there. 

You can find a simple example model using CoreOS [here](https://github.com/gem-test/vaquero).
A more complex example in a heterogeneous environment, with a multistage boot can be found [here](https://github.com/gem-test/vaquero/tree/multi)

We treat this data model as a "single source of truth" (SoT) that describes the operating state of your datacenter. The data model is [parsed and verified](https://ciscocloud.github.io/vaquero-docs/docs/current/validator.html) by a Vaquero Controller, and then deployed to an on-site Vaquero Agent for execution.

## Key Concepts

Your datacenter is expressed as an inventory of _hosts_. Each host belongs to a _host group_. Each host group uses a combination of _unattended assets_ and _operating system_ definitions to define a target configured state for a host.

## Vocabulary

*Site*: A managed datacenter, or group of machines managed by a single Vaquero Agent. 

*Host*: A single managed machine. Definition includes identifying attributes (selectors), host-specific metadata, information for LOM (IPMI), and an association to a single host group.

*Operating System*: An "installation" template containing the details to perform a network boot into a particular OS, specifying kernel, initrd, boot command-line parameters, unattended config, etc.

*Unattended Assets*: An optionally templated unattended config/script (i.e. cloud-init, ignition, kickstart, etc) used for unattended boot and installation operations.

*Host Group*: A collection that ties together operating systems and unattended assets. Describes a target state for hosts to reach.

## Where things go

Configuration files are placed in a directory hierarchy. Vaquero parses site configurations by reading files placed in specially named subdirectories. The root of your configuration path has four directories:

1. *assets*: Assets grouped by type. These are generally unattended configs/scripts that have been templated to include environment-specific information. Contains named subdirectories (more on that later).
2. *os*: Individual documents describing family, version, kernel/image location, and boot/installation options for any operating systems used by host groups.
3. *host_groups*: Individual documents combining operating system and unattended asset information to describe a target host state.
4. *sites*: One or more sites (each in it's own subdirectory) that share the same host_group, os, and asset definitions. Each site includes environment-specific information, and an inventory of hosts that apply host_group definitions to machines.


```
.
├── assets
├── os
├── host_groups
└── sites
```

### Assets

Assets are grouped into named subdirectories based on type. There are currently four types:

1. Cloud-Config: [CoreOS Cloudinit System](https://coreos.com/os/docs/latest/cloud-config.html)
2. Ignition: [CoreOS Ignition](https://coreos.com/ignition/docs/latest/)
3. Kickstart: [Fedora Project Kickstart](http://fedoraproject.org/wiki/Anaconda/Kickstart)
4. Untyped: Misc files. Can be used for "unsupported" configuration types. 

Each asset is placed under a subdirectory according to it's type. Assets are referenced by file name from host groups:

```
.
└── assets
    ├── ignition
    │   ├── etcd.yml
    │   └── raid-fmt.yml
    ├── cloud-config
    │   └── base.yml
    ├── kickstart
    │   └── clevos.yml
    └── untyped
        ├── autoyast.xml
        └── preseed.cfg
 ```

Validation is performed on typed assets to verify that rendered templates produce valid configurations.

Assets are retrieved dynamically from the Vaquero Agent through typed endpoints. Query parameters are included in the request to render the asset for a particular host:
- `/cloud-config` -- Cloud-config assets
- `/ignition` -- Ignition assets
- `/kickstart` -- Kickstart assets
- `/untyped` -- Untyped assets

So a host with mac address `00:00:00:00:00:01` could retrieve it's rendered ignition configuration by requesting
```
<agent_url>:<agent_port>/ignition?mac=00:00:00:00:00:01
```

### Operating Systems

Operating systems exist as individual documents under the `os` subdirectory. They are referenced by a self-assigned ID described in the document:

```
.
└── os
    ├── centos-7.yml
    ├── clevos-3.yml
    └── coreos-1053.12.0.yml
```

### Host Groups

Host groups exist as individual documents under the `host_groups` subdirectory. They are referenced by a self-assigned ID described in the document:

```
.
└── host_groups
    ├── etcd-cluster.yml
    └── etcd-proxy.yml
```

### Sites

Sites are represented by individual subdirectories. One directory == one site == one managed group of machines. Each SoT can contain multiple sites. Each of these sites shares the same assets/host_groups/os configuration files.

Each site has _at least_ two documents, the specially named `env.yml` and at least one document describing an inventory of hosts. You may use YAML's triple-dash `---` separator to combine multiple inventory documents into one file.

```
.
└── sites
    ├── site-a
    │   ├── env.yml
    │   └── inventory.yml
    └── site-a
        ├── env.yml
        ├── inventory.yml
        └── another-inv.yml
```

## Rough Workflow

Configurations are roughly executed in the following order:

1. Host makes DHCP request. 
2. DHCP causes host to chainload iPXE (undionly.kpxe) and indicates Vaquero Agent as next-server
3. Vaquero Agent provides default iPXE script to discover basic host information (mac, uuid, domain, hostname)
4. Host requests dynamic iPXE script based on basic information
5. Vaquero Agent renders iPXE script using os, host_group, and host information
6. Host executes iPXE script, requesting resources (kernel, intitrd, unattended configs/scripts) as required

The default ipxe script chains back to Vaquero Agent, injecting basic information:
```
#!ipxe
chain ipxe?uuid=${uuid}&mac=${net0/mac:hexhyp}&domain=${domain}&hostname=${hostname}&domain=${domain}
```

## Serving files

Vaquero Agent will expose an endpoint `/file` for hosting static content. This endpoint acts transparently as a file server, or a reverse proxy, according to configuration.

## Identifying a Host

A booting machine is identified as a particular host based on the selecting information used. Currently, a host will be identified by `mac` and `uuid`, as reported by iPXE.

Additionally, a specific callback may be made to Vaquero Agent that includes a custom selection parameter

```
curl "{{.agent.url}}:{{.agent.port}}/ignition?mac={{.host.mac}}&os=installed" -o ignition.json
```

When identifying a host, Vaquero Agent will:

1. Only select a host where all the selectors apply
2. Select the host where the most selectors apply

So for two hosts:
```
---
host_group: group_one
hosts:
- name: host1
  selectors:
    mac: 00:00:00:00:00:01
---
host_group: group_two
hosts:
- name: host1_plus_some
  selectors:
    mac: 00:00:00:00:00:01
    os: installed
```
For a host requesting `/ignition?mac=00:00:00:00:00:01`, group_one will be matched (rule #1).
For a host requesting `/ignition?mac=00:00:00:00:00:01&os=installed`, group_two will be matched (rule #2).


## Metadata and Templating

Templates are written using [Go's standard templates](https://golang.org/pkg/text/template/). Templated information occurs in the following areas:

1. In any files under `assets`
2. In os objects in `boot.kernel`, `boot.initrd`, and values in `cmdline`

Metadata is used primarily to render templated information. It is "unstructured" data, that consists of nested key-value maps, and lists.

Metadata is included in three separate places in your configuration:

1. In the environment `env.yml` file
2. In a host_group file
3. In an inventory document, under each host

Metadata is made available during template execution as separate fields under the template's "dot". The fields are:

1. `.env` for environmental metadata
2. `.agent` for Vaquero Agent information (all fields from the `agent` object)
3. `.group` for host_group metadata
4. `.host` for host metadata, selectors, and limited information discovered via iPXE (mac, uuid, domain, hostname).

By way of example, this template snippet defines a networkd configuration:
```
networkd:
  units:
    - name: 10-static.network
      contents: |
        [Match]
        MACAddress={{.host.mac}}
        [Network]
        Gateway={{.env.networkd_gateway}}
        DNS={{.env.networkd_dns}}
        Address={{.host.networkd_address}}
```
`.host.mac` is from the host's selectors, `.host.networkd_address` and the `.env` fields are specified as metadata in their respective documents.

### Hosts with iPXE

Host information for templating includes the following information, discovered via [iPXE](http://ipxe.org/cfg):

1. mac
2. domain
3. hostname
4. uuid

### TEMPLATING TODO

As a future feature, we will define a series of well defined helper functions that will make for more succinct and readable templates.

For example,
```
boot:
  kernel: {{.agent.url}}:{{.agent.port}}/file/coreos_production_pxe.vmlinuz
```

Might be replaced with,
```
boot:
  kernel: {{ AgentFileServer }}/coreos_production_pxe.vmlinuz
```
Where `AgentFileServer` is a built-in function that translates to `{{.agent.url}}:{{.agent.port}}/file`.

## Translation to iPXE

Currently, all network boots/installations are performed using iPXE scripts. Operating system boot parameters and cmdline options are translated into iPXE scripts to perform boot/installation tasks.

Any unattended configs/scripts included in a host_group are inserted during this process. Inconsistencies (i.e. using ignition for a CentOS os) should be detected during validation.

### Cmdline Parameters

Rules for translating cmdline parameters:

1. Keys with empty values (i.e. "" or '') are formatted as `key` in the boot options
2. Keys with non-empty values are formatted as `key=value` in the boot options

So for the os
```
---
id: centos-example
major_version: '7'
minor_version: '2'
os_family: CentOS
release_name: stable
boot:
  kernel: centos_kernel
  initrd:
  - centos_initrd
cmdline:
  console: ttyS0,115200
  lang: ' '
  debug: ''
  enforcing: ''
```

The iPXE script will be roughly generated as (not taking unattended info from host_group):
```
#!ipxe

kernel centos_kernel console=ttyS0,115200 lang=  debug enforcing
initrd centos_initrd
boot
```

Note how `lang` appears with a trailing `=`, because it's value was non-empty `' '`


## Schemas

Some more proper schemas for the various objects.

### host_group

Defines a configured state (combination of os w/ unattended configuration and metadata) that may be applied to a group of hosts.

|       name       |                  description                  | required |         schema        | default |
|------------------|-----------------------------------------------|----------|-----------------------|---------|
| id               | A self-assigned identifier (should be unique) | yes      | string                |         |
| name             | A human-readable name for this group          | no       | string                | id      |
| operating_system | The ID of the os associated with this group   | yes      | string                |         |
| unattended       | Unattended config/script details              | no       | host_group.unattended |         |
| metadata         | unstructured, host_group-specific information | no       | object                |         |

#### host_group.unattended

Allow a network boot or installation to proceed automatically by providing canned answers.

| name |                       description                       | required | schema | default |
|------|---------------------------------------------------------|----------|--------|---------|
| type | The type of unattended config/script to use             | yes      | string |         |
| use  | The file name used to find the unattended config/script | yes      | string |         |


### inventory

Define a collection of hosts that will be configured according to a specific host_group.

|    name    |          description          | required |   schema   | default |
|------------|-------------------------------|----------|------------|---------|
| host_group | host_group id                 | yes      | string     |         |
| hosts      | A list of hosts in this group | yes      | host array |         |

#### inv.host

Details for single-hosts bmc

|    name   |                     description                      | required | schema | default |
|-----------|------------------------------------------------------|----------|--------|---------|
| name      | unique name among hosts in the same group            | yes      | string |         |
| selectors | map of string keys/values used to identify this host | yes      | object |         |
| bmc       | Details for connecting to the host's BMC             | no       | bmc    |         |
| metadata  | unstructured, host-specific information              | no       | object |         |

#### inv.bmc (ipmi)

Details for single-hosts bmc, used for LOM of the host machine.

NOTE: Only IPMI is supported at this time.

| name |          description          | required | schema | default |
|------|-------------------------------|----------|--------|---------|
| type | The type of BMC the host uses | yes      | string | ipmi    |
| ip   | IP Address of IPMI interface  | yes      | string |         |
| mac  | MAC Address of IPMI inteface  | no       | string |         |
| user | Configured user               | yes      | string |         |
| pass | Configured password           | yes      | string |         |


### env

Provides information for a single deployment/datacenter/etc.

|   name   |                        description                        | required |   schema  | default |
|----------|-----------------------------------------------------------|----------|-----------|---------|
| id       | A self-assigned identifier (should be unique)             | yes      | string    |         |
| name     | A human-readable name for this group                      | no       | string    | id      |
| agent    | Details for establishing a connection to the site's agent | yes      | env.agent |         |
| metadata | unstructured, site-specific information                   | no       | object    |         |

#### env.agent

Details for establishing a connection to a site's agent

|     name    |              description              | required |  schema |      default      |
|-------------|---------------------------------------|----------|---------|-------------------|
| url         | Insecure/local url for reaching agent | yes      | string  | http://127.0.0.1  |
| port        | Port for insecure URL                 | yes      | integer | 80                |
| secure_url  | Secure/remote url for reaching agent  | yes      | string  | https://127.0.0.1 |
| secure_port | Port for secure URL                   | yes      | integer | 443               |

The transport (http/s) should be included with the agent URL.

### os

Represents a single operating system with boot/installation parameters.

|      name     |           description            | required |  schema | default |
|---------------|----------------------------------|----------|---------|---------|
| id            | self-assigned identifier         | yes      | string  |         |
| name          | human-readable name              | yes      | string  | id      |
| major_version | major version                    | yes      | string  |         |
| minor_version | minor version                    | no       | string  |         |
| os_family     | family (i.e. CoreOS, CentOS)     | yes      | string  |         |
| release_name  | release name (i.e. stable, beta) | no       | string  |         |
| boot          | kernal & initrd img info         | yes      | os.boot |         |
| cmdline       | boot/installation options        | no       | object  |         |

Cmdline values may be templated. They will be rendered on-demand for inidividual hosts.

#### os.boot

Contains information about the kernal/initrds for an operating system.

|  name  |               description               | required |    schema    | default |
|--------|-----------------------------------------|----------|--------------|---------|
| kernel | URL for retrieving kernel on boot       | yes      | string       |         |
| initrd | URL for retrieving initrds/imgs on boot | yes      | string array |         |


Kernel and initrd values may be templated. They will be rendered on-demand for inidividual hosts.