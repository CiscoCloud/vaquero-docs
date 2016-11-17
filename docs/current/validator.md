<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Validator</title>
            <link rel="stylesheet" type="text/css" href="../doc.css">
            <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans:300,300italic,400,400italic,600,600italic%7CNoto+Serif:400,400italic,700,700italic%7CDroid+Sans+Mono:400">
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

# Vaquero Validator

[Home](https://ciscocloud.github.io/vaquero-docs/) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

The Vaquero validator is a built in utility for checking the consistency of your configurations. Its purpose is to preemptively report any inconsistencies (mistyped IDs, missing metadata, etc) in your configuration before you attempt to deploy it.

## Using vaquero validate

- Validating a local SoT: `vaquero validate --sot-dir <base_directory>` The base directory structure should be consistent with the [data model](data-model-howto.html).
- Validating a git SoT: `vaquero validate --config sa-config.yml` The config file should contain all the parameters required to start vaquero in server mode, specifically GitHook and SoT fields.

## Validation Process

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
