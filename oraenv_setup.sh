##########################################
## Oracle Basic Environment

##########################################
## /home/oracle/.oraenv
## (gets called by bashrc - see below)

# .oraenv

ORAENV=${HOME}/oraenv
export ORAENV

## source Oracle Environment
test -a ${ORAENV}/ORA.env && {
  # set default SID if present
  test -a ${ORAENV}/ORA.sid && source ${ORAENV}/ORA.sid || true
  ## Default ORACLE_SID env file
  if [ ! -z ${DEFAULT_ORACLE_SID} ]; then
    test -a ${ORAENV}/${DEFAULT_ORACLE_SID}.env && \
  source ${ORAENV}/${DEFAULT_ORACLE_SID}.env || {
    echo "A Default ORACLE_SID [${DEFAULT_ORACLE_SID}] is specified,"
    echo "but no ${ORAENV}/${DEFAULT_ORACLE_SID}.env was found!";
      ## if none is found just return true
      false
    }
  fi
  ## source remaining env
  source ${ORAENV}/ORA.env
  # source depneding files, only if ORA.env was found
  test -a ${ORAENV}/ORA.alias && source ${ORAENV}/ORA.alias || true
  test -a ${ORAENV}/ORA.fnc && source ${ORAENV}/ORA.fnc || true
  } || {
    echo "No ORA.env found!";
    false;
}


##########################################
## /home/oracle/.bash_profile (sources oracle env)

# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs
if [ -f ~/.oraenv ]; then
        . ~/.oraenv
fi

##########################################
## Default Files in $HOME/oracle/oraenv directory

## ORA.sid

## Default ORACLE_SID
export DEFAULT_ORACLE_SID=MYDWH
## Default TNS Listener
export LSNR=LISTENER_MYDWH

## Start/Stop of Oracle Services
#SID_LIST="sid1 sid2 sid2"
#LSNR_LIST="lsnr1 lsnr2 lsnr3"
#ORDS_LIST="ords1 ords2 ords3"
#for s in $SID_LIST; do ...; done


## ORA.env

## Default ORACLE_SID comes from value of variable OSID in ORA.sid.
## If secified in this file, the Default is overwritten
export ORACLE_SID=${DEFAULT_ORACLE_SID}
## Oracle Environment
export ORACLE_BASE=/opt/oracle
export OB=${ORACLE_BASE}
export ORACLE_VERSION=21
export OV=${ORACLE_VERSION}
export ORACLE_HOME=/opt/oracle/product/${OV}
export OH=${ORACLE_HOME}
export ORACLE_DIAG=${ORACLE_BASE}/diag
export OD=${ORACLE_DIAG}
export ORA_INVENTORY=${HOME}/oraInventory
export ORACLE_HOSTNAME=$(hostname)
export TNS_ADMIN=${ORACLE_HOME}/network/admin
export TNSD=${TNS_ADMIN}
## Shell
export SHELL=/usr/bin/bash
## Editor
export EDITOR=/usr/bin/vim
## further environment
export ENVDIR=${HOME}/oraenv


## MYDWH.env
ORACLE_SID=MYDWH
export ORACLE_SID
##### only uncomment and set if a different home is used
# ORACLE_HOME=${ORACLE_HOME}
# export ORACLE_HOME


## ORA.alias
alias ostat='ps -U oracle -u oracle u |grep -v grep | grep -E ["pmon|lsnr|ords|sudo"]'
alias oraps='ps -ef|grep -v grep|grep -e [pmon]'
alias os='echo ${ORACLE_SID}'
alias ob='echo ${ORACLE_BASE}'
alias oh='echo ${ORACLE_HOME}'
alias od='echo ${ORACLE_DIAG}'
alias oenv='set|grep ORA'
alias cdo='cd ${ORACLE_BASE}'
alias cdb='cd ${ORACLE_HOME}/bin'
alias cdh='cd ${ORACLE_HOME}'
alias cdp='cd ${ORACLE_BASE}/product'
alias net='cd ${ORACLE_HOME}/network/admin'
alias cdd='cd ${ORACLE_DIAG}'


## ORA.fnc
set -o emacs



##########################################
## Requirements for local install w.o. internet access
## (user root)

## create a local YUM repository by copying contents from install media to local directory

## list block devices and find mounted usb stick (dev/sdb1 in this case)
lsblk

## create mount dir
mkdir -p /media/usb

## mount usb to directory
mount /dev/sdb /media/usb

## create software directory
mkdir -p /usr/local/ol8

## copy all files from usb to local directory
cp -a -T /media/usb .

## disable all repositories in /etc/yum.repos.d./ by setting enabled=0 in all files
vi oracle-linux-ol8.repo
vi uek-ol8.repo
vi virt-ol8.repo

## disable dnf
dnf config-manager --disable \*

## create a local *.repo file in /etc/yum.repos.d.
## "/etc/yum.repos.d/oracle-linux-ol8-local.repo" and add:
[OL8_BaseOS]
name=Oracle Linux 8 x86_64 ISO  BaseOS
baseurl=file:///usr/local/ol8/BaseOS
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[OL8_AppStream]
name=Oracle Linux 8 x86_64 ISO AppStream
baseurl=file:///usr/local/ol8/AppStream
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

## clean dnf cache
dnf clean all

#[root@ol8 yum.repos.d]# dnf clean all
#0 files removed

## list repositories
dnf repolist

#[root@ol8 yum.repos.d]# dnf repolist
# repo id                      repo name
# OL8_AppStream                Oracle Linux 8 x86_64 ISO AppStream
# OL8_BaseOS                   Oracle Linux 8 x86_64 ISO  BaseOS

## test install by installing some dnf repo util
dnf install -y dnf-utils createrepo

## install required packages
dnf install -y bc   \
binutils  \
compat-openssl10  \
elfutils-libelf  \
glibc  \
glibc-devel  \
ksh  \
libaio  \
libXrender  \
libX11  \
libXau  \
libXi  \
libXtst  \
libgcc  \
libnsl  \
libstdc++  \
libxcb  \
libibverbs  \
make  \
policycoreutils  \
policycoreutils-python-utils  \
smartmontools  \
sysstat

## Log:
# [root@ol8 ~]# dnf install -y bc   \
# > binutils  \
# > compat-openssl10  \
# > elfutils-libelf  \
# > glibc  \
# > glibc-devel  \
# > ksh  \
# > libaio  \
# > libXrender  \
# > libX11  \
# > libXau  \
# > libXi  \
# > libXtst  \
# > libgcc  \
# > libnsl  \
# > libstdc++  \
# > libxcb  \
# > libibverbs  \
# > make  \
# > policycoreutils  \
# > policycoreutils-python-utils  \
# > smartmontools  \
# > sysstat  \
# >
# Last metadata expiration check: 0:02:14 ago on Sun 02 Jan 2022 09:19:38 PM CET.
# Package bc-1.07.1-5.el8.x86_64 is already installed.
# Package binutils-2.30-108.0.2.el8.x86_64 is already installed.
# Package elfutils-libelf-0.185-1.el8.x86_64 is already installed.
# Package glibc-2.28-164.0.1.el8.x86_64 is already installed.
# Package glibc-devel-2.28-164.0.1.el8.x86_64 is already installed.
# Package libaio-0.3.112-1.el8.x86_64 is already installed.
# Package libXrender-0.9.10-7.el8.x86_64 is already installed.
# Package libX11-1.6.8-5.el8.x86_64 is already installed.
# Package libXau-1.0.9-3.el8.x86_64 is already installed.
# Package libXi-1.7.10-1.el8.x86_64 is already installed.
# Package libgcc-8.5.0-3.0.2.el8.x86_64 is already installed.
# Package libstdc++-8.5.0-3.0.2.el8.x86_64 is already installed.
# Package libxcb-1.13.1-1.el8.x86_64 is already installed.
# Package libibverbs-35.0-1.el8.x86_64 is already installed.
# Package make-1:4.2.1-10.el8.x86_64 is already installed.
# Package policycoreutils-2.9-16.0.1.el8.x86_64 is already installed.
# Package policycoreutils-python-utils-2.9-16.0.1.el8.noarch is already installed.
# Package smartmontools-1:7.1-1.el8.x86_64 is already installed.
# Dependencies resolved.
# ===============================================================================
#  Package          Arch   Version                           Repository     Size
# ===============================================================================
# Installing:
#  compat-openssl10 x86_64 1:1.0.2o-3.el8                    OL8_AppStream 1.1 M
#  ksh              x86_64 20120801-254.0.1.el8              OL8_AppStream 927 k
#  libXtst          x86_64 1.2.3-7.el8                       OL8_AppStream  22 k
#  libnsl           x86_64 2.28-164.0.1.el8                  OL8_BaseOS    104 k
#  sysstat          x86_64 11.7.3-6.0.1.el8                  OL8_AppStream 425 k
# Installing dependencies:
#  lm_sensors-libs  x86_64 3.4.0-23.20180522git70f7e08.el8   OL8_BaseOS     59 k

# Transaction Summary
# ===============================================================================
# Install  6 Packages

# Total size: 2.6 M
# Installed size: 8.1 M
# Downloading Packages:
# Running transaction check
# Transaction check succeeded.
# Running transaction test
# Transaction test succeeded.
# Running transaction
#   Preparing        :                                                       1/1
#   Installing       : lm_sensors-libs-3.4.0-23.20180522git70f7e08.el8.x86   1/6
#   Running scriptlet: lm_sensors-libs-3.4.0-23.20180522git70f7e08.el8.x86   1/6
#   Installing       : sysstat-11.7.3-6.0.1.el8.x86_64                       2/6
#   Running scriptlet: sysstat-11.7.3-6.0.1.el8.x86_64                       2/6
#   Installing       : libXtst-1.2.3-7.el8.x86_64                            3/6
#   Installing       : ksh-20120801-254.0.1.el8.x86_64                       4/6
#   Running scriptlet: ksh-20120801-254.0.1.el8.x86_64                       4/6
#   Installing       : compat-openssl10-1:1.0.2o-3.el8.x86_64                5/6
#   Running scriptlet: compat-openssl10-1:1.0.2o-3.el8.x86_64                5/6
#   Installing       : libnsl-2.28-164.0.1.el8.x86_64                        6/6
#   Running scriptlet: libnsl-2.28-164.0.1.el8.x86_64                        6/6
#   Verifying        : libnsl-2.28-164.0.1.el8.x86_64                        1/6
#   Verifying        : lm_sensors-libs-3.4.0-23.20180522git70f7e08.el8.x86   2/6
#   Verifying        : compat-openssl10-1:1.0.2o-3.el8.x86_64                3/6
#   Verifying        : ksh-20120801-254.0.1.el8.x86_64                       4/6
#   Verifying        : libXtst-1.2.3-7.el8.x86_64                            5/6
#   Verifying        : sysstat-11.7.3-6.0.1.el8.x86_64                       6/6

# Installed:
#   compat-openssl10-1:1.0.2o-3.el8.x86_64
#   ksh-20120801-254.0.1.el8.x86_64
#   libXtst-1.2.3-7.el8.x86_64
#   libnsl-2.28-164.0.1.el8.x86_64
#   lm_sensors-libs-3.4.0-23.20180522git70f7e08.el8.x86_64
#   sysstat-11.7.3-6.0.1.el8.x86_64

# Complete!
# [root@ol8 ~]# dnf install -y bc   \
# > binutils  \
# > compat-openssl10  \
# > elfutils-libelf  \
# > glibc  \
# > glibc-devel  \
# > ksh  \
# > libaio  \
# > libXrender  \
# > libX11  \
# > libXau  \
# > libXi  \
# > libXtst  \
# > libgcc  \
# > libnsl  \
# > libstdc++  \
# > libxcb  \
# > libibverbs  \
# > make  \
# > policycoreutils  \
# > policycoreutils-python-utils  \
# > smartmontools  \
# > sysstat
# Last metadata expiration check: 0:02:41 ago on Sun 02 Jan 2022 09:19:38 PM CET.
# Package bc-1.07.1-5.el8.x86_64 is already installed.
# Package binutils-2.30-108.0.2.el8.x86_64 is already installed.
# Package compat-openssl10-1:1.0.2o-3.el8.x86_64 is already installed.
# Package elfutils-libelf-0.185-1.el8.x86_64 is already installed.
# Package glibc-2.28-164.0.1.el8.x86_64 is already installed.
# Package glibc-devel-2.28-164.0.1.el8.x86_64 is already installed.
# Package ksh-20120801-254.0.1.el8.x86_64 is already installed.
# Package libaio-0.3.112-1.el8.x86_64 is already installed.
# Package libXrender-0.9.10-7.el8.x86_64 is already installed.
# Package libX11-1.6.8-5.el8.x86_64 is already installed.
# Package libXau-1.0.9-3.el8.x86_64 is already installed.
# Package libXi-1.7.10-1.el8.x86_64 is already installed.
# Package libXtst-1.2.3-7.el8.x86_64 is already installed.
# Package libgcc-8.5.0-3.0.2.el8.x86_64 is already installed.
# Package libnsl-2.28-164.0.1.el8.x86_64 is already installed.
# Package libstdc++-8.5.0-3.0.2.el8.x86_64 is already installed.
# Package libxcb-1.13.1-1.el8.x86_64 is already installed.
# Package libibverbs-35.0-1.el8.x86_64 is already installed.
# Package make-1:4.2.1-10.el8.x86_64 is already installed.
# Package policycoreutils-2.9-16.0.1.el8.x86_64 is already installed.
# Package policycoreutils-python-utils-2.9-16.0.1.el8.noarch is already installed.
# Package smartmontools-1:7.1-1.el8.x86_64 is already installed.
# Package sysstat-11.7.3-6.0.1.el8.x86_64 is already installed.
# Dependencies resolved.
# Nothing to do.
# Complete!

## set locale
localectl set-locale en_US.UTF-8

# [root@ol8 ~]# localectl set-locale en_US.UTF-8
# [root@ol8 ~]# localectl set-locale LANG=en_US.UTF-8
# [root@ol8 ~]#


######################################################
## Install Oracle Software (as user oracle)

## create inventory location in /home/oracle
mkdir /home/oracle/oraInventory

## set variables ORA_INVENTORY and ORACLE_HOSTNAME in /home/oracle/oraenv/ORA.env

cd ${ORACLE_HOME}
unzip -oq /home/oracle/install/Database/LINUX.X64_213000_db_home.zip

./runInstaller -ignorePrereq -waitforcompletion -silent \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp \
    oracle.install.option=INSTALL_DB_SWONLY \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \
    UNIX_GROUP_NAME=oinstall \
    INVENTORY_LOCATION=${ORA_INVENTORY} \
    SELECTED_LANGUAGES=en,en_GB \
    ORACLE_HOME=${ORACLE_HOME} \
    ORACLE_BASE=${ORACLE_BASE} \
    oracle.install.db.InstallEdition=EE \
    oracle.install.db.OSDBA_GROUP=dba \
    oracle.install.db.OSBACKUPDBA_GROUP=dba \
    oracle.install.db.OSDGDBA_GROUP=dba \
    oracle.install.db.OSKMDBA_GROUP=dba \
    oracle.install.db.OSRACDBA_GROUP=dba \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
    DECLINE_SECURITY_UPDATES=true


# [oracle@ol8 21]$ ./runInstaller -ignorePrereq -waitforcompletion -silent     -responseFile ${ORACLE_HOME}/install/response/db_install.rsp     oracle.install.option=INSTALL_DB_SWONLY     ORACLE_HOSTNAME=${ORACLE_HOSTNAME}     UNIX_GROUP_NAME=oinstall     INVENTORY_LOCATION=${ORA_INVENTORY}     SELECTED_LANGUAGES=en,en_GB     ORACLE_HOME=${ORACLE_HOME}     ORACLE_BASE=${ORACLE_BASE}     oracle.install.db.InstallEdition=EE     oracle.install.db.OSDBA_GROUP=dba     oracle.install.db.OSBACKUPDBA_GROUP=dba     oracle.install.db.OSDGDBA_GROUP=dba     oracle.install.db.OSKMDBA_GROUP=dba     oracle.install.db.OSRACDBA_GROUP=dba     SECURITY_UPDATES_VIA_MYORACLESUPPORT=false     DECLINE_SECURITY_UPDATES=true
# perl: warning: Setting locale failed.
# perl: warning: Please check that your locale settings:
# 	LANGUAGE = (unset),
# 	LC_ALL = (unset),
# 	LC_CTYPE = "UTF-8",
# 	LANG = "en_US.UTF-8"
#     are supported and installed on your system.
# perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
# Launching Oracle Database Setup Wizard...

# [WARNING] [INS-13014] Target environment does not meet some optional requirements.
#    CAUSE: Some of the optional prerequisites are not met. See logs for details. installActions2022-01-02_10-00-03PM.log
#    ACTION: Identify the list of failed prerequisite checks from the log: installActions2022-01-02_10-00-03PM.log. Then either from the log file or from installation manual find the appropriate configuration to meet the prerequisites and fix it manually.
# The response file for this session can be found at:
#  /opt/oracle/product/21/install/response/db_2022-01-02_10-00-03PM.rsp

# You can find the log of this install session at:
#  /tmp/InstallActions2022-01-02_10-00-03PM/installActions2022-01-02_10-00-03PM.log


# As a root user, execute the following script(s):
# 	1. /home/oracle/oraInventory/orainstRoot.sh
# 	2. /opt/oracle/product/21/root.sh

# Execute /home/oracle/oraInventory/orainstRoot.sh on the following nodes:
# [ol8]
# Execute /opt/oracle/product/21/root.sh on the following nodes:
# [ol8]


# Successfully Setup Software with warning(s).
# Moved the install session logs to:
#  /home/oracle/oraInventory/logs/InstallActions2022-01-02_10-00-03PM

# [oracle@ol8 21]$ sudo su -
# [sudo] password for oracle:
# [root@ol8 ~]# /home/oracle/oraInventory/orainstRoot.sh
# Changing permissions of /home/oracle/oraInventory.
# Adding read,write permissions for group.
# Removing read,write,execute permissions for world.

# Changing groupname of /home/oracle/oraInventory to oinstall.
# The execution of the script is complete.
# [root@ol8 ~]# /opt/oracle/product/21/root.sh
# Check /opt/oracle/product/21/install/root_ol8.bls.biz_2022-01-02_22-08-58-975235396.log for the output of root script

# [oracle@ol8 21]$ echo $PATH
# /home/oracle/.local/bin:/home/oracle/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
# [oracle@ol8 21]$ export PATH=$ORACLE_HOME/bin:$PATH
# [oracle@ol8 21]$ sqlplus

# SQL*Plus: Release 21.0.0.0.0 - Production on Sun Jan 2 22:10:24 2022
# Version 21.3.0.0.0

# Copyright (c) 1982, 2021, Oracle.  All rights reserved.

# Enter user-name: / as sysdba
# Connected to an idle instance.

# SQL>