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
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://10.128.0.53/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" > /etc/yum.repos.d/NTI-320.repo
# start by installing the repos for mariadb 10 (required by cacti)

echo "# MariaDB 10.1 CentOS repository list - created 2016-01-18 09:58 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" > /etc/yum.repos.d/MariaDB10.repo

yum clean all 

yum -y install MariaDB-server MariaDB-client 

yum -y install cacti               # Installes a number of packages, including mariadb, httpd, php and so on
                                   # If you want to have multiple cacti nodes, considder using the client and connecting
                                   # to another server
                                   
yum -y install php-process php-gd php mod_php
yum -y install net-snmp net-snmp-utils                                   
                    
systemctl enable mariadb           # Enable db, apache and snmp (not cacti yet)
systemctl enable httpd
systemctl enable snmpd


systemctl start mariadb           # Start db, apache and snmp (not cacti yet)
systemctl start httpd
systemctl start snmpd

mysqladmin -u root password P@ssw0rd1                               # Set your mysql/mariadb pasword.  here *** is your password
                                                                    # Make a sql script to create a cacti db and grant the cacti user access to it

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -pP@ssw0rd1 mysql    # Transfer your local timezone info to mysql

echo "create database cacti;
GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'P@ssw0rd1';  
FLUSH privileges;
GRANT SELECT ON mysql.time_zone_name TO cacti@localhost;            
flush privileges;" > stuff.sql


mysql -u root  -pP@ssw0rd1 < stuff.sql    # Run your sql script
rpm -ql cacti|grep cacti.sql     # Will list the location of the package cacti sql script
                                 # In this case, the output is /usr/share/doc/cacti-1.0.4/cacti.sql, run that to populate your db

mypath=$(rpm -ql cacti|grep cacti.sql)
mysql cacti < $mypath -u cacti -pP@ssw0rd1
  
#mysql -u cacti -p cacti < /usr/share/doc/cacti-1.0.4/cacti.sql

# Open up apache
sed -i 's/Require host localhost/Require all granted/' /etc/httpd/conf.d/cacti.conf
sed -i 's/Allow from localhost/Allow from all all/' /etc/httpd/conf.d/cacti.conf

# Modify cacti credencials to use user cacti P@ssw0rd1
sed -i "s/\$database_username = 'cactiuser';/\$database_username = 'cacti';/" /etc/cacti/db.php
sed -i "s/\$database_password = 'cactiuser';/\$database_password = 'P@ssw0rd1';/" /etc/cacti/db.php


# Fix the php.ini script
cp /etc/php.ini /etc/php.ini.orig
sed -i 's/;date.timezone =/date.timezone = America\/Regina/' /etc/php.ini
sed -i '1379i\[session]' /etc/php.ini
sed -i 's/session.auto_start = 0/session.auto_start = On/g' /etc/php.ini

systemctl restart httpd.service

# Set up the cacti cron
sed -i 's/#//g' /etc/cron.d/cacti
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config  # Disable it perminately
systemctl restart httpd
