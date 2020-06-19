#!/bin/bash
for file in $( ls /etc/yum.repos.d/ ); do mv /etc/yum.repos.d/$file /etc/yum.repos.d/$file.bak; done
echo "[nti-310-epel]
name=NTI310 EPEL
baseurl=http://104.197.59.12/epel
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo
echo "[nti-310-base]
name=NTI310 BASE
baseurl=http://104.197.59.12/base
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo
echo "[nti-310-extras]
name=NTI310 EXTRAS
baseurl=http://104.197.59.12/extras/
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo
echo "[nti-310-updates]
name=NTI310 UPDATES
baseurl=http://104.197.59.12/updates/
gpgcheck=0
enabled=1" >> /etc/yum.repos.d/local-repo.repo


yum -y install nagios
systemctl enable nagios
systemctl start nagios



setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

systemctl enable httpd
systemctl start httpd

yum -y install nrpe
systemctl enable nrpe
systemctl start nrpe
yum -y install nagios-plugins-all
yum -y install nagios-plugins-nrpe

htpasswd -b /etc/nagios/passwd nagiosadmin nagiosadmin
sed -i 's,allowed_hosts=127.0.0.1,allowed_hosts=127.0.0.1\, 10.128.0.0\/20, g' /etc/nagios/nrpe.cfg


sed -i 's,dont_blame_nrpe=0,dont_blame_nrpe=1,g' /etc/nagios/nrpe.cfg


mkdir /etc/nagios/servers
sed -i 's,#cfg_dir=/etc/nagios/servers,cfg_dir=/etc/nagios/servers,g' /etc/nagios/nagios.cfg
echo 'define command{
                          command_name check_nrpe
                          command_line /usr/lib64/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
                          }' >> /etc/nagios/objects/commands.cfg     
                          
echo "command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/disk" >> /etc/nagios/nrpe.cfg
echo "command[check_mem]=/usr/lib64/nagios/plugins/check_mem.sh -w 80 -c 90" >> /etc/nagios/nrpe.cfg
systemctl restart nagios

chmod 775 /etc/nagios/servers
usermod -a -G root irishman253

yum -y install wget
cd /etc/nagios
wget https://raw.githubusercontent.com/nic-instruction/hello-nti-320/master/generate_config.sh
#bash generate_config.sh example 10.128.0.48
systemctl restart nagios

# Now take a break, and spin up a machine called example-a with all the nrpe plugins installed and a propperly configured path 
# to nagios
# put it’s ip address and hostname insto generate_config.sh

#Further configuration:
#https://assets.nagios.eom/downloads/nagioscore/docs/nagioscore/4/en/monitoring-publicservices.html (Links to an external site.}

#verify
#/usr/sbin/nagios -v /etc/nagios/nagios.cfg

