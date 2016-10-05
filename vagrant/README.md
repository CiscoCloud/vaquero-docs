# Getting Started

1. `vagrant up`

2. `vagrant ssh vaquero`

3. `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`

4. `docker run -v /vagrant/config/git-server.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

## More details

## Source of Truth source options:
  - git: `vagrant/config/git-*.yaml`
  - local directory: `vagrant/config/vagrant-local.yaml`

## DHCP Deployment examples
  1. Vaquero utilizing its own DHCP server in "server" mode with no other DHCP in play.
    1. `vagrant up vaquero_server`
    2. `vagrant ssh vaquero_server`
    3. `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
    4. `docker run -v /vagrant/config/git-server.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`
  2. Vaquero **not** running its own DHCP or TFTP. Depending on DNSMASQ to provide that functionality. [dnsmasq.conf](https://github.com/CiscoCloud/vaquero/blob/master/vagrant/provision_files/dnsmasq-netboot.conf) used on `vaquero_dnsmasq` to provide DHCP & TFTP.
    1. `vagrant up vaquero_dnsmasq`
    2. `vagrant ssh vaquero_dnsmasq`
    3. `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
    4. `docker run -v /vagrant/config/git-dnsmasq.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`
  3. Vaquero running its own DHCP in proxy mode, the subnet has an existing DHCP server handing out IP addresses. [dnsmasq.conf](https://github.com/CiscoCloud/vaquero/blob/master/vagrant/provision_files/dnsmasq-iponly.conf) used by the `dnsmasq` box to provide only IPs.
    1. `vagrant up vaquero_proxy dnsmasq`
    2. `vagrant ssh vaquero_proxy`
    3. `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
    4. `docker run -v /vagrant/config/git-proxy.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

## Using a directory as an SoT
 `docker run -v /vagrant/config/vagrant-local.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files -v /vagrant/local:/vagrant/local --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

vagrant-local.yaml: Update from the data model at `./vagrant/local`
vagrant-git.yaml: Update from the data model at `https://github.com/gem-test/vaquero/tree/vagrant` (requires forwarding via ngrok for webhook updates, read below)


## Sending a webhook to the vaquero machine
- Assumes 'Getting Started' is complete

1. Install [ngrok] (https://ngrok.com/) to your local machine, unzip the package, and move the executable to `/usr/local/bin`.
2. Run ngrok on your physical machine `ngrok http 8888`.
3. Create a testing repo to launch webhooks from.
4. Give github.com the http endpoint provided by ngrok.
5. Launch a webhook by pushing to the repo, or asking github to `Redeliver Payload` to hit the ngrok address.

## Building an example etcd-cluster
- Assumes 'Getting Started' is complete

1. Run `./cluster.sh -c 2` in `vagrant/create_cluster`
2. Open the node machines in virtualbox, wait for them to PXE boot (~5 minutes)
3. Check etcd `etcdctl cluster-health`

This environment will start up one etcd-proxy and etcd-master.
