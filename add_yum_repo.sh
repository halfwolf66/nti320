#!/bin/bash
# this is a script to add a yum repo on a given server.

ip="10.128.0.13"                                                    # Please replace with your own IP

echo "[nti-320]
name=Extra Packages for Centos from NTI-320 7 - $basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch <- example epel repo
# Note, this is putting repodata at packages instead of 7 and our path is a hack around that.
baseurl=http://$ip/centos/7/extras/x86_64/Packages/
enabled=1
gpgcheck=0
" >> /etc/yum.repos.d/NTI-320.repo                                  
                                                                    # Now that the repo is added, list all repos and make sure
                                                                    # it shows up without error
yum repolist

yum search hello-world
                     
