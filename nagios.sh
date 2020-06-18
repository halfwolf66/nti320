#!/bin/bash

yum -y install nagios           #install, start and enable nagios
systemctl enable nagios
systemctl start nagios

chmod 775 /etc/nagios/servers
usermod -a -G root irishman253

setenforce 0                    # turn off SELinux, so it doesn't trip us up
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config  #disable it perminatly

systemctl enable httpd          # Enable and start apache
systemctl start httpd

yum -y install nrpe             #install, enable, and start nrpe, the nagios client
systemctl enable nrpe
systemctl start nrpe
yum -y install nagios-plugins-all
yum -y install nagios-plugins-nrpe

htpasswd -b /etc/nagios/passwd nagiosadmin nagiosadmin      #set the nagios admin password
sed -i 's,allowed_hosts=127.0.0.1,allowed_hosts=127.0.0.1\, 10.128.0.47\/20, g' /etc/nagios/nrpe.cfg
#enables connections from the subnet please adjust to your subnet.

sed -i 's,dont_blame_nrpe=0,dont_blame_nrpe=1,g' /etc/nagios/nrpe.cfg
#enables NRPE monitoring

mkdir /etc/nagios/servers
#create a directory for our server configuration and enable it in the config file
sed -i 's,#cfg_dir=/etc/nagios/servers,cfg_dir=/etc/nagios/servers,g' /etc/nagios/nagios.cfg
echo 'define command{
                          command_name check_nrpe
                          command_line /usr/lib64/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
                          }' >> /etc/nagios/objects/commands.cfg                          


#yum -y install wget
#cd /etc/nagios
#wget https://raw.githubusercontent.com/nic-instruction/hello-nti-320/master/generate_config.sh
#bash generate_config.sh example 10.128.0.48
#systemctl restart nagios

# Now take a break, and spin up a machine called example-a with all the nrpe plugins installed and a propperly configured path 
# to nagios
# put it’s ip address and hostname insto generate_config.sh

#Further configuration:
#https://assets.nagios.eom/downloads/nagioscore/docs/nagioscore/4/en/monitoring-publicservices.html (Links to an external site.}

#verify
#/usr/sbin/nagios -v /etc/nagios/nagios.cfg

