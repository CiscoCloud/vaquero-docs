# Gemini / Vaquero

A bare metal configuration tool that leverages github templates, and CoreOS bare-metal to net boot machines. 

## Architecture
![Architecture] (architecture.png)

## [Data Model Templates] (https://github.com/CiscoCloud/gemini/blob/master/docs/env-data-structure.md)

## [Requirements] (https://github.com/CiscoCloud/gemini/blob/master/docs/design/requirements.md)

## Running Vaquero
1. Fetch the image: `docker login -u gem-test -p f42556869fc7c81ec066e150f769b9c03cf4385b shippedrepos-docker-gemini.bintray.io && docker pull shippedrepos-docker-gemini.bintray.io/gemini/gemini:0.1`
2. Run: `docker run shippedrepos-docker-gemini.bintray.io/gemini/gemini:0.1`

## Dev Environment: Pre-Reqs

1. [Golang] (https://golang.org/) environment
2. pkg-config
3. libssl-dev
4. [libgit2] (https://libgit2.github.com/). Mac OSX: `brew install libgit2`. Linux: Clone our repo and run `./libgit2.sh`. Windows: Bootcamp to Linux / OSX.

## Dev Environment: Fetching / Compiling / Running code

1. `git clone https://github.com/CiscoCloud/gemini.git` the Gemini repo under `$GOPATH/src/github.com/ciscocloud/`.
2. Build gemini binary `make`.
3. Run the gemini binary `.bin/gemini -config config.json`.


## Sending Webhooks to Vaquero Master

1. Install [ngrok] (https://ngrok.com/) to your local machine, unzip the package, and move the executable to `/usr/local/bin`.
2. Run ngrok on your physical machine `ngrok http 4816`.
3. Create a testing repo to launch webhooks from.
4. Give github.com the http endpoint provided by ngrok. 
5. Launch a webhook to hit the ngrok address.

## CI System
[Drone/CI Documentation] (https://github.com/CiscoCloud/gemini/blob/master/docs/continuous-integration.md)

## Contributing
See our [Contributing Guide] (https://github.com/CiscoCloud/gemini/blob/master/CONTRIBUTING.md)

## Docs
Build the documentation by running `godoc -http <port>` and open localhost:<port> on your web browser