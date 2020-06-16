Name:		nti-320-plugins
Version: 	0.1
Release:	1%{?dist}
Summary: 	NTI-320 NRPE plugins

Group:		NTI-320
License:	GPL2+
URL:		https://github.com/nic-instruction/NTI-320
Source0:	https://github.com/nic-instruction/nti-320-plugins-0.1.tar.gz

BuildRequires:	gcc, python >= 1.3
Requires:	nrpe, nagios-plugins-all, bash, net-snmp, net-snmp-utils, rsyslog, nagios-plugins-load, nagios-plugins-ping, nagios-plugins-disk, nagios-plugins-http, nagios-plugins-procs, wget  

%description
'nti-320-plugins' provides custom NRPE plugins
written by the NTI-320 class of 2020 with some additional fixes for our gcloud/centos 7 
environment.

%prep								

%setup -q	
		
%build					
%define _unpackaged_files_terminate_build 0

%install

rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/lib64/nagios/plugins/
mkdir -p %{buildroot}/etc/nrpe.d/
mkdir -p %{buildroot}/etc/sudoers.d/

install -m 0744 nti320.cfg %{buildroot}/etc/nrpe.d/
install -m 0440 nrpe_sudoers %{buildroot}/etc/sudoers.d/
install -m 0755 * %{buildroot}/usr/lib64/nagios/plugins/


%clean

%files					
%defattr(-,root,root)	
/usr/lib64/nagios/plugins/check_create_ldap.sh
/usr/lib64/nagios/plugins/check_http.sh
/usr/lib64/nagios/plugins/djangostatus.sh
/usr/lib64/nagios/plugins/ldap-status.sh
/usr/lib64/nagios/plugins/nfs_check.sh
/usr/lib64/nagios/plugins/nfs_read_write.sh
/usr/lib64/nagios/plugins/nfsclientcheck.sh

%config
/etc/nrpe.d/nti320.cfg
/etc/sudoers.d/nrpe_sudoers
%doc			

%post

nagiosip="10.128.0.4"
rsyslogip="10.128.0.15"
cactiip="10.128.0.9"

touch /thisworked

mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig

echo '# create myuser in mygroup authenticating with 'public' community string and source network '$cactiip'/24
com2sec myUser '$cactiip'/24 public
# myUser is added into the group 'myGroup' and the permission of the group is defined
group    myGroup    v1        myUser
group    myGroup    v2c        myUser
view all included .1
access myGroup    ""    any    noauth     exact    all    all    none' >> /etc/snmp/snmpd.conf


wget -O /usr/lib64/nagios/plugins/check_mem.sh https://raw.githubusercontent.com/nic-instruction/hello-nti-320/master/check_mem.sh
chmod +x /usr/lib64/nagios/plugins/check_mem.sh
sed -i "s/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1, $nagiosip/g" /etc/nagios/nrpe.cfg
echo "command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/disk" >> /etc/nagios/nrpe.cfg
echo "command[check_mem]=/usr/lib64/nagios/plugins/check_mem.sh -w 80 -c 90" >> /etc/nagios/nrpe.cfg 


echo "*.info;mail.none;authpriv.none;cron.none   @$rsyslogip" >> /etc/rsyslog.conf



systemctl enable nrpe
systemctl restart nrpe
systemctl enable rsyslog
systemctl restart rsyslog
systemctl enable snmpd
systemctl restart snmpd

%postun
rm /etc/nrpe.d/nti320.cfg
rm /etc/sudoers.d/nrpe_sudoers
rm /thisworked
%changelog				# changes you (and others) have made and why
