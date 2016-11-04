<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Getting Started</title>
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

# DHCP Options
[Home](https://ciscocloud.github.io/vaquero-docs/)

[Docs Repo](https://github.com/CiscoCloud/vaquero-docs/tree/master)

Vaquero's DHCP server sends it's DHCP Options based on fields in `env.subnet`, defined
in the Data Model's `env.yaml.`

The options set implicitly by Vaquero are shown below:


| option tag | option name     | source                 |
|:-----------|:----------------|:-----------------------|
| 1          | subnet mask     | env.subnet.cidr        |
| 3          | router          | env.subnet.gateway     |
| 6          | DNS             | env.subnet.dns         |
| 12         | hostname        | env.subnet.hostname    |
| 15         | domain name     | env.subnet.domain_name |
| 42         | ntp servers     | env.subnet.ntp         |
| 43         | vendor specific | *                      |
| 54         | server id       | env.subnet.cidr        |

\* vendor specific is set by vaquero during PXEBoot.

## Custom Options
There may be a situation where additional options are required. Additional options
can be configured in the format defined in the data model [subnet docs](https://github.com/CiscoCloud/vaquero-docs/blob/master/docs/current/data-model-howto.md#envsubnet).

Below we list a few use cases for custom DHCP Options and the corresponding ```env.subnet.dhcp_options``` to use.
### Example 1: Custom IP Time-To-Live:

IP TTL is DHCP Option 23 and it's value is an unsigned 8 bit integer.
The following ```env.subnet.dhcp_option``` will set the TTL to 128:
```
dhcp_options:
    - option: 23
      type: uint8
      value: 128
```
### Example 2: Broadcast Address Option:
Using a custom Broadcast Address is DHCP Option 28 and it's value is 4 bytes
representing an ip address.
The following ```env.subnet.dhcp_options``` will set the broadcast address to "10.0.0.251":
```
dhcp_options:
    - option: 28
      type: addresses
      value: "10.0.0.251"
```

### Example 3: SMTP Servers Option:
Simple Mail Transport Protocol Servers are DHCP Option 69 and is a variable number of bytes representing a list of SMTP+ server ip addresses.
The following ```env.subnet.dhcp_options``` will set the SMTP+ option to "10.0.0.251,10.0.0.253,10.0.0.9":
```
dhcp_options:
    - option: 69
      type: addresses
      value: "10.0.0.251,10.0.0.253,10.0.0.9"
```
