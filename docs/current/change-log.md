---
layout: page
page.title: Changelog
---
<div align="center">
<img src="img/cow.png" alt="Drawing" style="width: 200px;"/>
  <p style="font-size:60px">vaquero</p>
[Home]({{ site.url }}) | [Dev Repo](https://github.com/CiscoCloud/vaquero) | [Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master) | [Project Requirements](requirements.html) | [Issue Tracking](https://waffle.io/CiscoCloud/vaquero)
</div>

# Change log

Vaquero container release history and change logs. All containers are served from [bintray](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero). We do not recommend using `latest` since it will be released once or day or more. Vaquero upgrades should be done from major version to major version, we do not provide backwards compatibility across more than 1 major release. Alpha(Pre 1.0) releases should be upgraded from minor release to minor release.


| Release                                                                       | Change log                                                                                                                                                                                                                   | Release Date | Size  |
|:------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------|:------|
| [latest](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/latest)   | - HEAD of the master branch                                                                                                                                                                                                  | daily        | NA    |
| [v0.14.0](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.14.0) | - State engine rollout policy <br> - Updates to improve state engine performance <br> - Custom reboot task for hosts <br> - Storage migration  | 3/10/2017     | 9.3MB |
| [v0.13.0](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.13.0) | - Initial state engine leveraging ipmi for power management <br> - More robust Agent to Server API client <br> - ssh power control added (support for non-ipmi machines) <br> - Shutdown bugs fixed for agent authentication | 2/7/2017     | 8.6MB |
| [v0.12.1](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.12.1) | - DM helpers to better specify interfaces. `Host.interfaces`, `bmcInterfaces`, `netInterfaces`                                                                                                                               | 1/18/2017    | 8.6MB |
| [v0.12](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.12)     | - Updated to go 1.7.1 <br> - Storage Bug fixes <br> - UEFI support <br> - Duplicate Site, DM, SoT detection <br> - Better CDN logging messages <br> - Preview / Validation inconsistency bug fixed                           | 1/17/2017    | 8.6MB |
| [v0.11.0](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.11.0) | - Intelligent JWT renewal <br> - Validate no longer supports pulling from git <br> - Server saving events from agents <br> - etcd storage support <br> - support for git tags in a data model                                | 12/14/2016   | 8.6MB |
| [v0.10.0](https://bintray.com/shippedrepos/vaquero/vaquero%3Avaquero/v0.10.0) | - Subnet validation <br> - Better configuration defaults and robustness around blank fields and invalid fields <br> - Agent Server communicates secured via [JWT](https://jwt.io/)                                           | 11/28/2016   | 8.6MB |
