<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Tools</title>
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

# Vaquero Tools

[Home](https://ciscocloud.github.io/vaquero-docs/) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master) | 
[Migrate](#vaquero-migrate) | [Preview](#vaquero-preview) | [Validator](#vaquero-validator)

## Vaquero Migrate
The Vaquero migrate tool is built for moving and renaming stored information about SoTs and Sites. 
By default, the tool will check for collisions in the destination storage. If it finds any, it will 
ask for the user to confirm to continue and overwrite any information.

Potential use cases include:
- Moving storage between any combination of `FileStorage` and `EtcdStorage`
- Checking if a storage migration would overwrite pre-existing information
- Renaming sites and SoTs
- Migrating specific sites or SoTs
- Disaster recovery via creating backups
- Debugging from a specific saved state
- Splitting up a vaquero server into multiple servers
- Migrating to a new storage system

### Using vaquero migrate

- Migrating files from one local storage to the destination etcd: 
`vaquero migrate --src <config_with_local>.yaml --dst <config_with_etcd>.yaml`
- Migrating and renaming an SoT:
`vaquero migrate --src <config>.yaml --dst <config>.yaml --src-sot <src_sot_id> --dst-sot <new_id> --del`

Options:

- `--src` __required__ 
    - The source config file containing either the etcd or savepath configurations.
- `--dst` __required__
    - The destination config file containing either the etcd or savepath configurations.
- `--src-sot` _optional_
    - The SoT id if moving a specific SoT from the source.
- `--src-site` _optional_
    - The site id if moving a specific site from the source. This requires having specified 
    the containing SoT with `--src-sot`.
- `--dst-sot` _optional_
    - The name for the destination SoT id. This requires having a source SoT specified.
- `--dst-site` _optional_
    - The name for the destination site id. This requires having the source and destiation
    SoTs specified.
- `--ovwrt` _optional_
    - This will disable checking for migration conflicts causing it to overwrite any saved
    information in the destination.
- `--del` _optional_
    - This will delete the source files targeted for migration.

### Example configs
Below are some configs showing valid configurations to provide to the migrate tool.

************************************************************
**sample-file-store.yaml:**
```
SavePath: "/var/vaquero"
```
**minimal-etcd-store.yaml:**
```
Etcd:
  Endpoints:
  - "http://127.0.0.1:2379"
```
**sample-etcd-store.yaml:**
```
Etcd:
  Root: "vaquero1"
  Endpoints:
  - "http://127.0.0.1:2379"
```
************************************************************

## Vaquero Preview
The Vaquero preview tool is built to prview iPXE and unattended boot scripts.

## Vaquero Validator
The Vaquero validator is a built in utility for checking the consistency of your configurations. Its purpose is to preemptively report any inconsistencies (mistyped IDs, missing metadata, etc) in your configuration before you attempt to deploy it.

### Using vaquero validate

- Validating a local SoT: `vaquero validate --sot <base_directory>` The base directory structure should be consistent with the [data model](data-model-howto.html).

### Validation Process

The validator first loads the directory tree passed in through a local directory, or through git. It then:

1. Checks if all links between objects exist. For example, an error would be generated if a `host_group` is looking for `operating_system: coreos-1053.2.0-stable` and the data model only has `coreos-1053.2.0-alpha`.
2. Checks if all metadata needed to render templates is available.
3. Checks unattended files are in a valid format
4. Checks unattended files mentioned are supported by Vaquero
5. Checks for name duplication amongst a class of data model objects
6. Checks if inventory has hosts
7. Checks if the ignition files provided are valid. Uses [coreos/fuze](https://github.com/coreos/fuze/tree/master/config)
8. Checks if the cloud-config files provided are valid. Uses [coreos/coreos-cloudinit](github.com/coreos/coreos-cloudinit/config)
9. Checks if the kickstart files provided are valid using a simple internally developed parser. Further validation can be done using the [official validator](http://fedoraproject.org/wiki/Pykickstart).
