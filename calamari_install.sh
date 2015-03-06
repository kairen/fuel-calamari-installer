#!/bin/sh

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
    ssh $node dpkg -i salt-stack_fix/*.deb
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

dpkg -i salt-stack_fix/master/*.deb
dpkg -i Calamari_package_fix/*.deb
dpkg -i cairo2/*.deb
dpkg -i calamari-server_1.3-rc-23-g4c41db3_amd64.deb
cp -rp opt/calamari/webapp/content/ /opt/calamari/webapp/content
ls -l /opt/calamari/webapp/content

sudo calamari-ctl initialize

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
