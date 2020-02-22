#!/bin/bash

## Set TimeZone to Asia/Ho_Chi_Minh
echo ">>>>> [TASK] Set TimeZone to Asia/Ho_Chi_Minh"
timedatectl set-timezone Asia/Ho_Chi_Minh

## Update the system >/dev/null 2>&1
echo ">>>>> [TASK] Updating the system"
yum install -y epel-release >/dev/null 2>&1
yum update -y >/dev/null 2>&1

## Install desired packages
echo ">>>>> [TASK] Installing desired packages"
yum install -y telnet htop net-tools wget nano >/dev/null 2>&1

## Enable password authentication
echo ">>>>> [TASK] Enabled SSH password authentication"
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
systemctl reload sshd

## Set Root Password
echo ">>>>> [TASK] Set root password"
echo "centos" | passwd --stdin root >/dev/null 2>&1

## Disable and Stop firewalld
echo ">>>>> [TASK] Disable and stop firewalld"
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

## Disable SELinux
echo ">>>>> [TASK] Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

## Update hosts file
echo ">>>>> [TASK] Update host file /etc/hosts"
cat >>/etc/hosts<<EOF
192.168.16.161 gitlab1.testlab.local gitlab1
192.168.16.151 docker1.testlab.local docker1
192.168.16.141 jenkins1.testlab.local jenkins1
192.168.16.130 kmaster.testlab.local kmaster
192.168.16.131 kworker1.testlab.local kworker1
192.168.16.132 kworker2.testlab.local kworker2
EOF

## Install Gitlab-CE on CentOS 7
echo ">>>>> [TASK] Install Gitlab-CE on CentOS 7"
yum -y install curl policycoreutils-python openssh-server >/dev/null 2>&1
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash >/dev/null 2>&1
EXTERNAL_URL="http://gitlab1.testlab.local" yum -y install gitlab-ce >/dev/null 2>&1
#install postfix
yum -y install postfix >/dev/null 2>&1
systemctl daemon-reload
systemctl start postfix
systemctl enable postfix >/dev/null 2>&1

## Cleanup system >/dev/null 2>&1
echo ">>>>> [TASK] Cleanup system"
package-cleanup -y --oldkernels --count=1 >/dev/null 2>&1
yum -y autoremove >/dev/null 2>&1
yum clean all >/dev/null 2>&1
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp
#dd if=/dev/zero of=/EMPTY bs=1M
#rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c
