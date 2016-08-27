<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
# Vaquero
[![Build Status](https://drone.projectshipped.io/api/badges/CiscoCloud/vaquero/status.svg)](https://drone.projectshipped.io/CiscoCloud/vaquero)
=======
# Gemini / Vaquero
<<<<<<< HEAD
>>>>>>> 59b1c42... Pushed version 1, for real
=======
# Vaquero
[![Build Status](https://drone.projectshipped.io/api/badges/CiscoCloud/vaquero/status.svg)](https://drone.projectshipped.io/CiscoCloud/vaquero)
>>>>>>> 98509d0... Attempted integration with drone
=======
>>>>>>> 59b1c42... Pushed version 1, for real

A bare metal configuration tool that leverages github templates, and CoreOS bare-metal to net boot machines.

<<<<<<< HEAD
<<<<<<< HEAD
# High Level Overview

## [Architecture] (https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html)
![arch](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/architecturediagram.png)
<<<<<<< HEAD

## [Data Model Templates] (https://github.com/CiscoCloud/vaquero-docs/blob/gh-pages/docs/current/env-data-structure.md)
=======
## Architecture
![Architecture] (architecture.png)

## [Data Model Templates] (https://github.com/CiscoCloud/gemini/blob/master/docs/env-data-structure.md)
>>>>>>> 59b1c42... Pushed version 1, for real

=======
# Vaquero
[![Build Status](https://drone.projectshipped.io/api/badges/CiscoCloud/vaquero/status.svg)](https://drone.projectshipped.io/CiscoCloud/vaquero)

A bare metal configuration tool that leverages github templates, and CoreOS bare-metal to net boot machines.

# High Level Overview

## [Architecture] (https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html)
![arch](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/architecturediagram.png)
=======
## Architecture
![Architecture] (architecture.png)

## [Data Model Templates] (https://github.com/CiscoCloud/gemini/blob/master/docs/env-data-structure.md)
>>>>>>> 59b1c42... Pushed version 1, for real

## [Data Model Templates] (https://github.com/CiscoCloud/vaquero-docs/blob/gh-pages/docs/current/env-data-structure.md)

>>>>>>> 04eed73... Initialized docs site to v1.0
=======

## [Data Model Templates] (https://github.com/CiscoCloud/vaquero-docs/blob/gh-pages/docs/current/env-data-structure.md)

>>>>>>> 98509d0... Attempted integration with drone
=======
=======
>>>>>>> f07cbda4360a5e0829c66f9291f99247830ed7fd
# Vaquero
[![Build Status](https://drone.projectshipped.io/api/badges/CiscoCloud/vaquero/status.svg)](https://drone.projectshipped.io/CiscoCloud/vaquero)

A bare metal configuration tool that leverages github templates, and CoreOS bare-metal to net boot machines.

# High Level Overview

## [Architecture] (https://ciscocloud.github.io/vaquero-docs/docs/current/architecture.html)
![arch](https://raw.githubusercontent.com/CiscoCloud/vaquero-docs/gh-pages/docs/current/architecturediagram.png)

## [Data Model Templates] (https://github.com/CiscoCloud/vaquero-docs/blob/gh-pages/docs/current/env-data-structure.md)

<<<<<<< HEAD
>>>>>>> 04eed73... Initialized docs site to v1.0
=======
>>>>>>> f07cbda4360a5e0829c66f9291f99247830ed7fd
## [Requirements] (https://ciscocloud.github.io/vaquero-docs/docs/current/requirements.html)

## Running Vaquero
1. Fetch the image: `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:0.1`
2. Run: `docker run shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:0.1`

## [Vaquero Validate] (https://ciscocloud.github.io/vaquero-docs/docs/current/validator.html)

## Dev Environment: Pre-Reqs

1. [Golang] (https://golang.org/) environment
2. pkg-config
3. libssl-dev
4. [libgit2] (https://libgit2.github.com/). Mac OSX: `brew install libgit2`. Linux: Clone our repo and run `./libgit2.sh`. Windows: Bootcamp to Linux / OSX.

## Dev Environment: Fetching / Compiling / Running code

1. `git clone https://github.com/CiscoCloud/vaquero.git` the Vaquero repo under `$GOPATH/src/github.com/CiscoCloud/`.
2. Build vaquero binary `make`.
3. Run the vaquero binary `.bin/vaquero <command> -config config.json`.


## Sending Webhooks to Vaquero Master

1. Install [ngrok] (https://ngrok.com/) to your local machine, unzip the package, and move the executable to `/usr/local/bin`.
2. Run ngrok on your physical machine `ngrok http 4816`.
3. Create a testing repo to launch webhooks from.
4. Give github.com the http endpoint provided by ngrok.
5. Launch a webhook to hit the ngrok address.

## Docs
Build the documentation by running `godoc -http <port>` and open localhost:<port> on your web browser
