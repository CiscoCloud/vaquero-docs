<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Documentation</title>
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

#Vaquero Validator
[Home](https://ciscocloud.github.io/vaquero-docs/)

The Vaquero validator is a built in utility for checking the consistency of your configurations. Its purpose is to preemptively report any inconsistencies (mistyped IDs, missing metadata, etc) in your configuration, before you attempt to deploy it.

## Using vaquero validate

Running `vaquero validate --sot-dir <base_directory>` The base directory structure should be consistent with the [data model](https://github.com/CiscoCloud/vaquero-docs/blob/gh-pages/docs/current/env-data-structure.md).

## Validation Process

The first thing validate does is load the directory tree passed to it.

- It checks if all links between objects exist

  - For example, an error would be generated if a `host_group` is looking for `operating_system: coreos-1053.2.0-stable` and the data model only has `coreos-1053.2.0-alpha`. 

- It checks if all metadata needed to render templates is available.

- It checks unattended files are in a valid format

- It checks unattended files mentioned are supported by Vaquero

- It checks for name duplication amongst a class of data model objects

- It checks if inventory has hosts

Validation also includes ensuring the ignition files provided are correct. Today we leverage [coreos/fuze](https://github.com/coreos/fuze/tree/master/config) as our method of validating ignition files.
