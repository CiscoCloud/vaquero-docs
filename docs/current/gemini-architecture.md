#Gemini Architecture
Gemini is bare metal configuration and management for Viper video apps. It provides centralized management for multi-site deployments, and life cycle management of CoreOS on bare metal running Kubernetes. 

[Diagram] (https://github.com/CiscoCloud/gemini/blob/master/docs/gemini-arch.png)

## High Level View
-	Implemented in Go
-	Deploying CoreOS on bare metal
-	Intended to be containerized
-	Packages Included:
  -	CoreOS bare-metal
  -	Go-github
-	Requirements
  -	Github templates as Source of Truth
  -	Routable end point to receive git webhook
  
##Components

###Storage Interface
The storage component that will store the standardized Gemini BM templates. In general the purpose is to retain the state of the desired templates of the systems described.

It is defined as an interface because it must be flexible to future needs, we want to use git as our storage today, but one might want a DB or other system to hold templates.

####Responsibilities
- Update local files/templates/etc
-	Queryable by Orchestrator for changes made. 
-	Listen for Updates from webhook or poll storage
  -	Pull or Push Model – we can support both by requiring a Storage module to define two interface functions, a listen and a start function. Listen is used in the push model, it defines an HTTP.listen() function for git webhooks. Start would be the closed loop that would poll the central storage every so often and update that way. One of the interfaces would be defined as a NO-OP depending on if you want a polling system or a push based system.

###Provisioner Interface
The provisioner component must be able to take [Gemini templates] (https://github.com/CiscoCloud/gemini/blob/master/docs/env-data-structure.md), and use that information to stand up a site. It has two components one component that would live in the centralized location acting as the master, and have a client at each site that would be taking action on its behalf.  It is responsible for knowing if actions taken on the machines require a restart and reporting that back to the orchestrator. It will report the current boot state back to the inventory. 

This is an interface to enable other provisioner types, we are implementing the CoreOS bare metal package, but it is foreseeable that other provisioners might be useful, such as foreman.

####Responsibilities
-	Translate standardized files/tmpls/etc into real bare metal configurations
-	Handle DHCP for subnet(possibly a relay)
-   Delivering boot images
-   Delivering kickstarts & equivalents
-	Knowing who needs reboots.
-	Report state to Orchestrator

###BMC Interface
The BMC component is required to manage firmware and staging system reboots. It does not take part in the PXE process, but will only serve to power cycle machines / firmware. It is possible for the BMC to have a client that will take action locally at each site.

This is an interface to enable other types of BMC, we will most likely implement IPMI here, but it is likely we would want USCM in the future.

####Responsibilities
-	Life cycle management
-	Firmware upgrade/downgrade
-	Report power status to orchestrator

###Inventory
The aggregated database of all current statuses reported from sites. Queryable so the orchestrator can know what is going on in every site. 

####Responsibilities
-	Store current state of every host and site

###Gemctl
The REST interface that enables one to configure, query site information, update templates, and kick off power cycles / new builds. Update the DHCP manager.
####Responsibilities
-	Provide a programmatic interface for configuration and all CRUD operations on Storage, Provisioner, BMC, DHCP and Orchestrator.

###Orchestrator / Gemgine
The central component that ties all the interfaces together. This will resolve if the current state found in inventory matches the desired state found via the storage interface. If differences are found it will pass updates to the provisioner and wait for a response. If necessary it will talk to the BMC to reboot machines that require it. It will not provide any translation, it will only deal with Gemini templates and be the only way to interface with the inventory DB.
####Responsibilities
-	Note differences between the current state and desired template state
-	Notify provisioner to take action
-	Update Inventory with current status it receives from Provisioner and BMC

##Current Implementation
-	Implementing the ‘github’ Storage Interface
-	Implementing the ‘CoreOS bare metal’ Provisioner Interface
-	Implementing the ‘IPMI’ BMC Interface

##Open Questions
-	What exactly is inventory? How much do we want for current state / health? 
-	How will we do fact collection? 
-	How do we get current state / health?
  -	Is site health critical here, or is that out of scope for what Gemini is built for?
  -	If we have health checking, do we have to deploy it to each machine, how will that happen?
-	BMC remote service vs. centralized service
  -	Baked into Gemini or extensible out of Gemini?
-	Do we want to bake in DHCP management like foreman, or force the user to manage their own DHCP like CoreOS bare metal does?
  - Danehans - suggesting this should be a responsibility of the provisioner interface. We need to work upstream in bootcfg to include it.
-	Container strategy?
  -	What will the micro-services be?
  -	How will we deploy / manage?
-	Deployment Strategy for master and site client.
-	How will we handle Scalability?
-	How will we handle Reliability?
