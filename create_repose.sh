
#!/bin/bash

yum -y install createrepo                                                          # Install createrepo

mkdir -p /repos/centos/7/extras/x86_64/Packages/                                   # Make your repo dir

cp hello-world-1-1.x86_64.rpm /repos/centos/7/extras/x86_64/Packages   # Replace 'helloworld*' with your package

createrepo --update /repos/centos/7/extras/x86_64/Packages/                        # Update after every change




yum -y install httpd                                                              # Now install apache so you can serve your repo over the web

setenforce 0

systemctl enable httpd

systemctl start httpd

ln -s  /repos/centos /var/www/html/centos                                         # Link your repos in

cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak                      # Make a copy of our origonal httpd.conf

sed -i '144i     Options All' /etc/httpd/conf/httpd.conf                          # Configure apache
sed -i '145i    # Disable directory index so that it will index our repos' /etc/httpd/conf/httpd.conf
sed -i '146i     DirectoryIndex disabled' /etc/httpd/conf/httpd.conf

sed -i 's/^/#/' /etc/httpd/conf.d/welcome.conf                                    # Disables the defualt welcome page in the recommended way

chown -R apache:apache /repos/

systemctl restart httpd


# At this point you should be able to see your repository structure when you hit the website

# Last step is to configure your new yum repository on a client:


