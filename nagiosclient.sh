#!/bin/bash
yum install -y nagios-plugins nrpe nagios-plugins-load nagios-plugins-ping nagios-plugins-disk nagios-plugins-http nagios-plugins-procs wget nagios-plugins-all
yum -y install nagios-plugins-all
# BUG:https://osric.com/chris/accidental-developer/2016/12/missing-nagios-plugins-in-centos-7/ (nrpc plugins have been packaged seperately and don't install with nagio plugins-all)
# BUG #2 https://cloudwafer.com/blog/installing-nagios-agent-npre-on-centos/ (the nrpe config is commented out and checks are not defined)
# Use sed statments to uncomment NRPE config and add the appropiate flags Ü add in command[check_mem]=/usr/lib64/nagios/plugins/check_mem.sh # Install custom mem monitor
wget -O /usr/lib64/nagios/plugins/check_mem.sh https://raw.githubusercontent.com/nic-instruction/hello-nti-320/master/check_mem.sh 
chmod +x /usr/lib64/nagios/plugins/check_mem.sh 
systemctl enable nrpe 
systemctl start nrpe
sed -i 's/allowed_hosts=127.0.0.l/allowed_hosts=127.0.0.1, 10.128.0.48,/g' /etc/nagios/nrpe.cfg
sed -i "s,command[check_hdal]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/hdal,command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/sdal,g" /etc/nagios/nrpe.cfg 
systemctl restart nrpe
echo "command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/disk" >> /etc/nagios/nrpe.cfg
echo "command[check_mem]=/usr/lib64/nagios/plugins/check_mem.sh -w 80 -c 90" >> /etc/nagios/nrpe.cfg

#	From nagios server: /usr/lib64/nagios/plugins/check_nrpe -H 10.0.0.3 -c check_load From NRPE server execute the command in libexec /usr/lib64/nagios/plugins/
