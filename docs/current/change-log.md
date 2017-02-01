<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero README</title>
            <link rel="stylesheet" type="text/css" href="../doc.css">
            <link rel='shortcut icon' href='cow.png' type='image/x-icon'/ >
            <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans:300,300italic,400,400italic,600,600italic%7CNoto+Serif:400,400italic,700,700italic%7CDroid+Sans+Mono:400">
            <style>
                .markdown-body {
                    box-sizing: border-box;
                    min-width: 200px;
                    max-width: 1100px;
                    margin: 0 auto;
                    padding: 45px;
                }
            </style>
</head><article class="markdown-body">

<div align="center">
<img src="cow.png" alt="Drawing" style="width: 200px;"/>
  <p style="font-size:60px">vaquero</p>
[Home](https://ciscocloud.github.io/vaquero-docs/) | [Dev Repo](https://github.com/CiscoCloud/vaquero) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master) | [Project Requirements](requirements.html) | [Issue Tracking](https://waffle.io/CiscoCloud/vaquero)
</div>

# Change log

Vaquero container release history and change logs. All containers are served from [bintray](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero). We do not recommend using `latest` since it will be released once or day or more. Vaquero upgrades should be done from major version to major version, we do not provide backwards compatibility across more than 1 major release. Alpha(Pre 1.0) releases should be upgraded from minor release to minor release.


| Release                                                                       | Change log                                                                                                                                                                                         | Release Date | Size  |
|:------------------------------------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------|:------|
| [latest](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/latest)   | - HEAD of the master development branch                                                                                                                                                            | daily        | NA    |
| [v0.12.1](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.12.1) | - DM helpers to better specify interfaces. `Host.interfaces`, `bmcInterfaces`, `netInterfaces`                                                                                                     | 1/18/2017    | 8.6MB |
| [v0.12](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.12)     | - Updated to go 1.7.1 <br> - Storage Bug fixes <br> - UEFI support <br> - Duplicate Site, DM, SoT detection <br> - Better CDN logging messages <br> - Preview / Validation inconsistency bug fixed | 1/17/2017    | 8.6MB |
| [v0.11.0](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.11.0) | - Intelligent JWT renewal <br> - Validate no longer supports pulling from git <br> - Server saving events from agents <br> - etcd storage support <br> - support for git tags in a data model      | 12/14/2016   | 8.6MB |
| [v0.10.0](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.10.0) | - Subnet validation <br> - Better configuration defaults and robustness around blank fields and invalid fields <br> - Agent Server communicates secured via [JWT](https://jwt.io/)                 | 11/28/2016   | 8.6MB |
