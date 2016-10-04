VERSION=2.76
wget http://www.thekelleys.org.uk/dnsmasq/dnsmasq-$VERSION.tar.gz
tar -zxvf dnsmasq-$VERSION.tar.gz

rm dnsmasq-$VERSION.tar.gz

cd dnsmasq-$VERSION

make -j 10
sudo make install

sudo cp /vagrant/provision_files/dnsmasq-netboot.conf /etc/dnsmasq.conf

sudo mkdir /var/ftpd
cd ~
wget http://boot.ipxe.org/undionly.kpxe
sudo mv undionly.kpxe /var/ftpd

sudo systemctl restart dnsmasq.service
