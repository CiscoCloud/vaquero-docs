# Continuous Integration for Vaquero

[Drone](https://github.com/drone/drone) is used to build the Vaquero project. One of the advantages of the Drone system is that it executes all builds within containers, and all build instructions are stored within the repo along with this code. These two characteristics help ensure that the output of the build system (the artifact) is highly consistent even in the face of rebuilds tied to a specific revision.

To help manage the build process and versioning, a Makefile has been introduced. This should remain relatively static for the life of the project, but it currently has two targets defined:

* `make test` -- this target executes the unit tests built into the Vaquero software, filtering tests provided by external systems.
* `make` or `make all` -- this target executes the build, and creates the output binary at `bin/vaquero`

Upon successful completetion of the build, Drone will package the output binary into a lightweight Docker container (built on top of the [official Alpine Linux](https://hub.docker.com/_/alpine/) image), and push the container to a Docker repository. A downstream deployment could (potentially) watch the repository for updates, and deploy updated containers automatically.

With Drone, it is possible to execute builds locally within the same container-based environment using a CLI. To install the CLI on Windows or Linux, please refer to the upstream [documentation](http://readme.drone.io/0.5/reference/cli/overview/).

To install the CLI on OS X using [Homebrew](http://brew.sh/), please follow these steps:

1. Tap the repository to ensure availability of the appropriate formula for Homebrew:

  `brew tap drone/drone`

  _Example:_

  ```shell
  $ brew tap drone/drone
  ==> Tapping drone/drone
  Cloning into '/usr/local/Library/Taps/drone/homebrew-drone'...
  remote: Counting objects: 5, done.
  remote: Compressing objects: 100% (5/5), done.
  remote: Total 5 (delta 0), reused 3 (delta 0), pack-reused 0
  Unpacking objects: 100% (5/5), done.
  Checking connectivity... done.
  Tapped 1 formula (29 files, 37.2K)
  ```

2. Install the `devel` version of the CLI to get the version to be used with Drone v0.5:

  `brew install drone/drone/drone --devel`

  _Example:_

  ```shell
  $ brew install drone/drone/drone --devel
  ==> Installing drone from drone/drone
  ==> Downloading http://downloads.drone.io/release/darwin/amd64/drone.tar.gz
  ######################################################################## 100.0%
  🍺  /usr/local/Cellar/drone/0.5: 2 files, 19.5M, built in 19 seconds
  ```

You should now have the correct version of the Drone CLI installed.

## Running Local Tests

At the top project directory

`drone exec .drone.yml`

## Re-running tests on shipped.io
1. Add the Shipped Token and URL to your environment.
    - Go to [shipped] (https://drone.projectshipped.io/CiscoCloud/gemini) and click to your own account page. Click **Show Token**. Copy it and paste it in your `.bash_profile` or equivalent under `DRONE_TOKEN`
    - In your `.bash_profile` or equivalent add `DRONE_SERVER=https://drone.projectshipped.io`

2. Test a build
    - Go to the project build [summary page] (https://drone.projectshipped.io/CiscoCloud/gemini) and pick a build number you want to use. Then run `drone build start CiscoCloud/gemini <build_number>


## Signing drone.yml on edits
1. If edits are made to `.drone.yml` you must sign it by running `drone sign CiscoCloud/gemini`
