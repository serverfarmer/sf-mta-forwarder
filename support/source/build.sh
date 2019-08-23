#!/bin/sh

yum install wget make gcc openssl-devel rpm-build

# wget http://download-ib01.fedoraproject.org/pub/epel/7/SRPMS/Packages/s/ssmtp-2.64-14.el7.src.rpm
rpmbuild --rebuild ssmtp-2.64-14.el7.src.rpm
