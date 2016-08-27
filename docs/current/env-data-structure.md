<link rel="stylesheet" type="text/css" href="../doc.css"">


# Overview

Proposal for the representation of environment/configuration for baremetal provisioning.

The goal of this structure is to create a Source of Truth (SoT) that describes baremetal deployments across multiple/unassociated sites.

# Key Concepts

Strike a balance between:

  - Reusability: Should be able to reuse definitions as much as possible to keep large changes to many hosts manageable (think 1000s of machines per environment).
  - Readability: Do not obfuscate information to the point of being unreadable. Where not hugely contrary to reusability, aim for structures that are easy to read and understand. When possible, consolidate metadata in one place.

## Source of Truth

The directory structure:

	.
	├── assets
	│   └── ignition
	│       ├── etcd.yaml
	│       └── etcd-proxy.yaml
	├── os
	│   ├── centos-7.yaml
	│   └── coreos-1053.12.0.yaml
	├── host_groups
	│   ├── etcd-cluster.yaml
	│   └── etcd-proxy.yaml
	└── sites
	    ├── site-a
	    │   ├── env.yaml
	    │   └── inventory.yaml
	    └── site-a
	        ├── env.yaml
	        └── inventory.yaml

## Changelog

* Writing Templates
  * Added section about writing templates, and how collections of information interact on the system.
* Inventory (NOTE: removed INI proposal from previous revision)
  * Each site has an inventory file that:
	1. Assigns hosts to a group (host -\> host\_group)
	2. Provides selectors required to identify this host
	3. Provides host-specific metadata
* Simplify and flatten structure
  * Host groups now exist at the top level and are shared among sites (like operating systems have been)
  * no more per-site assets
  * each site now has only two files: `env.yaml` and `inventory[.ini]`
* Condensed metadata
  * metadata will be namespaced during templating. These are each "collections" of metadata. As opposed to merging metadata together.
	1. metadata from `env.yaml` will be under `env`
	2. metadata from each host group will be under `group`
	3. metadata from each host will be under `host`
  * A dedicated `host` collection will now exist when rendering any configuration templates. This will be populated with any information we have gained during the initial [iPXE chainloading][1]
* JSON -\> YAML
  * All documents have been shifted to yaml. Semantically, this does nothing to the data. It is just easier to compose/read.
* Operating System definition:
  * remove pw\_hash/password from operating system
  * move cmdline from host\_group -\> operating system (for now)


## Workflow

My envisioned workflow using this information:

  1. gemgine starts, and waits for changes to come in from any configured repository.
	a. When a webhook is received, it's repo url and branch are used to identify affected sites.
	b. Any affected sites continue through the workflow
  2. Fetch the environment for the sites identified (using key from binding file)
  3. For coreos-bm provisioner, use Hosts and Operating Systems to create profiles and groups for each host.
	a. For each group/profile after it is created, treat it as a template and try to apply the environment's metadata to each file.
  4. Render any assets (if the environment description and/or the asset file has been modified).
  5. Push all changed files to the remote hosts.


### Environments

An environment represents a collection of hosts that will be provisioned by our services. The environment manifest includes information on how to connect to the on-site provisioner, the subnets being managed by the provisioner, and a collection of arbitrary metadata that will be used to configure any installation files (cloud-init, ignition, kickstart, etc) as well as services (through systemd, fleet, etc).

Agent is a nested block with connection details that will be used to establish server-\>agent communication. `url` and `port` specify a local, insecure connection for hosts on the same subnet as the agent.


	---
	name: Virtualenv Dev
	id: test-site
	kind: pre-prod
	agent:
	  url: 10.10.10.9 # the site-local URL
	  port: 8080
	  secure_url: some.proper.domainname.com
	  secure_port: 443
	  cert_path: /etc/vaquero/certs/test-site.crt
	  # specify a specific root CA here? Or one CA to rule them all?
	metadata:
	  env_name: detroit-preprod
	  env_kind: pre-prod  

	  coreos_path: assets/coreos/1053.2.0/

	  etcd_initial_cluster: node1=http://10.10.10.10:2380,node2=http://10.10.10.11:2380,node3=http://10.10.10.12:2380
	  networkd_gateway: 172.15.0.1
	  networkd_dns: 172.15.0.3

	  ssh_authorized_keys: []


NOTE: Stay away from arrays where you need to access a single index. The templating gets ugly. It's okay if you have arrays where you'll cover the entire range.

### Inventory

Inventory is an association between a host and a host group. A file will be considered an inventory file if `inventory` is prepended to the file name.

A host matches a booting machine if _all_ selectors are present, and match. Selectors will be restricted to any information [pulled via iPXE][2], or stored in our stateful information about this machine (assuming the machine has booted before and have collected facts about it).



	---
	host_group: etcd-proxy
	hosts:
	- name: proxy1
	  selectors:
	    mac: 00:00:00:00:00:04
	- name: proxy2
	  selectors:
	    mac: 00:00:00:00:00:05
	---
	host_group: etcd-cluster
	hosts:
	- name: host1
	  selectors:
	    mac: 00:00:00:00:00:01
	  metadata:
	    ipv4: 10.10.10.10
	    networkd_address: 10.10.10.10/16
	    etcd_name: node1
	- name: host2
	  selectors:
	    mac: 00:00:00:00:00:02
	  metadata:
	    ipv4: 10.10.10.11
	    networkd_address: 10.10.10.11/16
	    etcd_name: node2
	- name: host3
	  selectors:
	    mac: 00:00:00:00:00:03
	  metadata:
	    ipv4: 10.10.10.12
	    networkd_address: 10.10.10.12/16
	    etcd_name: node3

#### BMC

Baseboard Management Controller configuration can be added to any host. The nested `bmc` block in each host will provide the details need to manage hardware lifecycle. Each implementation of bmc should have reasonable defaults if not specified.

This should be made pluggable so `cimc`/`ucsm`/etc can be added (eventually...)


	- name: proxy-host
	  selectors:
	    mac: 00:00:00:00:00:04
	  bmc:
	    type: ipmi
	    ip: 10.10.11.10
	    mac: 00:00:00:00:01:04
	    port: 623 # may be omitted


### Bindings

A binding ties a particular environment to a site. It represents an association between a single SoT. `source` has been included to keep the possibility for other sources to be used (eventually). For now, we can just assume every binding is to a git repository.

	```
	{
	    "site-id": {
	        "source": "git", //later can change to sqldb/filesystem/etc?
	        "repo": "github.com/myorgs/repo", //defaults to 'this' repo
	        "branch": "my-branch", //defaults master
	        "commit": "sha-sha-sha", //defaults to head of branch
	        "tags": "v1.1" //defaults to none
	        //credentials? Auth, tokens, etc?
	    },
	    "dev-syseng": {
	        "source": "git", //later can change to sqldb/filesystem/etc?
	        "repo": "https://github.comcast.com/viper-sde/belvedere",
	        "branch": "feature"
	        //remote repository/feature at head commit
	    },
	    "detroit-preprod": {
	        "source": "git"
	        "branch": "feature"
	        //this repository/feature at the head
	    },
	    "qa-performance": {
	        "source": "git"
	        "commit": "3b2664e421e441b75b3520722c42f0e0fe7e01e2"
	        //this repository/master at commit 3b2664
	    }
	}
	```

### Host Group

A _host group_ is a collection of hosts with identical structure or purpose. A host a single machine that will be managed by our provisioning service. It has two purposes: provide the provisioner with the details needed to identify the new host, and provide the files that will be needed to provision the host when it first boots. We can either specify metadata here, inject them from the environment metadata, or both.

Any cloud-config/ignition/generic templates or other assets are staged in the top level `assets` directory.

	---
	id: etcd-cluster
	name: Etcd Cluster
	operating_system: coreos-1053.2.0-stable

	unattended:
	  type: ignition
	  use: ignition/etcd.yaml

	metadata:
	  fleet_role: etcd


### Operating Systems

Operating systems specify the assets needed to boot a particular OS, and includes basic information on how to boot the OS. Like hosts, we can add placeholders here that will later be filled by environment (and agent) level metadata.


	---
	id: coreos-1053.2.0-stable
	name: CoreOS Stable 1053.2.0
	major_version: '1053'
	minor_version: '2.0'
	os_family: CoreOS
	release_name: stable
	boot:
	  kernel: "http://{{.agent.url}}:{{.agent.port}}/{{.env.coreos_path}}coreos_production_pxe.vmlinuz"
	  initrd:
	  - "http://{{.agent.url}}:{{.agent.port}}/{{.env.coreos_path}}coreos_production_pxe_image.cpio.gz"
	cmdline:
	  coreos.autologin: ''
	  coreos.first_boot: ''


### Writing Templates

Metadata from various sources is `namespaced` in templated files to make it as clear as possible where particular information is expected to be provided. There are three namespaces:
  * env: metadata gained from the environment the host lives in
  * group: collection of metadata gained from a hosts assigned host group
  * host: collection of metadata provided in the inventory file AND an stateful information we have about the host
  * agent: information about the provisioning agent. Not 100% sure what will exist here. `url` and `port` are a good start.


An example ignition file for etcd nodes:

	---
	systemd:
	  units:
	    - name: etcd2.service
	      enable: true
	      dropins:
	        - name: 40-etcd-cluster.conf
	          contents: |
	            [Service]
	            Environment="ETCD_NAME={{.host.etcd_name}}"
	            Environment="ETCD_ADVERTISE_CLIENT_URLS=http://{{.host.ipv4_address}}:2379"
	            Environment="ETCD_INITIAL_ADVERTISE_PEER_URLS=http://{{.host.ipv4_address}}:2380"
	            Environment="ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379"
	            Environment="ETCD_LISTEN_PEER_URLS=http://{{.host.ipv4_address}}:2380"
	            Environment="ETCD_INITIAL_CLUSTER={{.env.etcd_initial_cluster}}"
	            Environment="ETCD_STRICT_RECONFIG_CHECK=true"
	    - name: fleet.service
	      enable: true
	      dropins:
	        - name: fleet-metadata.conf
	          contents: |
	            [Service]
	            Environment="FLEET_METADATA=role={{.group.role}},name={{.host.etcd_name}}"
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
	{{ if index . ".env.ssh_authorized_keys" }}
	passwd:
	  users:
	    - name: core
	      ssh_authorized_keys:
	        {{ range $element := .env.ssh_authorized_keys }}
	        - {{$element}}
	        {{end}}
	{{end}}

[1]:	http://ipxe.org/cfg
[2]:	http://ipxe.org/cfg
