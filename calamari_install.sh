#!/bin/sh

echo "Generating locales ...."
locale-gen en_US.UTF-8
localedef -i en_US -f UTF-8 en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

echo "Installing Calamari ...."

MASTER_NODE_HOST=$(hostname)
echo "master: $MASTER_NODE_HOST" > minion
echo "Find MASTER_NODE : $MASTER_NODE_HOST"
echo "$(cat /etc/hosts | grep -o 'node-[0-9][0-9]')" > hosts

NODES=$(sort hosts | uniq)
IFS=$'
'
for node in $NODES; do
    echo "------------- Installing saltStack on $node  -------------"
    scp salt-stack_fix.tar $node:/root
    scp minion $node:/root
    ssh $node tar xvf salt-stack_fix.tar
    ssh $node sudo dpkg -i salt-stack_fix/*.deb
    ssh $node mv /etc/diamond/diamond.conf.example /etc/diamond/diamond.conf
    ssh $node mv minion /etc/salt/
    ssh $node service salt-minion restart && service diamond restart
    ssh $node rm -rf salt-stack_fix salt-stack_fix.tar
done
unset IFS

echo "------------- Installing Calamari on Master------------- "

tar xvf Calamari_package_fix.tar
tar xvf salt-stack_fix.tar
tar xvf cairo2.tar
tar xvf calamari-clients-build-output.tar

sudo dpkg -i tcl.deb 
sudo dpkg -i expect.deb
sudo dpkg -i salt-stack_fix/master/*.deb
sudo dpkg -i Calamari_package_fix/*.deb
sudo dpkg -i cairo2/*.deb
sudo dpkg -i calamari-server.deb
cp -rp opt/calamari/webapp/content/ /opt/calamari/webapp/content
ls -l /opt/calamari/webapp/content

expect initialize.sh

cp ports.conf /etc/apache2/
cp calamari.conf /etc/apache2/sites-available

rm -rf salt-stack_fix Calamari_package_fix cairo2 opt

iptables -I INPUT 1 -p tcp --dport 8008 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 4506 -j ACCEPT

service apache2 restart
service salt-master restart

echo "------------- ------------- ------------- "
echo "Install finish..."
echo "------------- ------------- ------------- "
