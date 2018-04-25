#!/bin/bash
set -x

if [ -e /etc/redhat-release ] ; then
  REDHAT_BASED=true
fi

TERRAFORM_VERSION="0.11.1"
PACKER_VERSION="0.10.2"
#
NOMAD_VERSION="0.7.1"
CONSUL_VERSION="1.0.6"
VAULT_VERSION="0.9.6"
# create new ssh key
[[ ! -f /home/ubuntu/.ssh/mykey ]] \
&& mkdir -p /home/ubuntu/.ssh \
&& ssh-keygen -f /home/ubuntu/.ssh/mykey -N '' \
&& chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# install packages
if [ ${REDHAT_BASED} ] ; then
  yum -y update
  yum install -y docker ansible unzip wget
else
  apt-get update
  apt-get -y install docker.io ansible unzip mc vim git
fi
# add docker privileges
usermod -G docker ubuntu
# install pip
pip install -U pip && pip3 install -U pip
if [[ $? == 127 ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python3 get-pip.py
fi
# install awscli and ebcli
pip install -U awscli
pip install -U awsebcli

#terraform
T_VERSION=$(/usr/local/bin/terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# packer
P_VERSION=$(/usr/local/bin/packer -v)
P_RETVAL=$?

[[ $P_VERSION != $PACKER_VERSION ]] || [[ $P_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip -o packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm packer_${PACKER_VERSION}_linux_amd64.zip

# nomad
N_VERSION=$(/usr/local/bin/nomad -v)
N_RETVAL=$?

[[ $N_VERSION != $NOMMAD_VERSION ]] || [[ $N_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip \
&& unzip -o nomad_${NOMAD_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm nomad_${NOMAD_VERSION}_linux_amd64.zip

# consul
C_VERSION=$(/usr/local/bin/consul -v)
C_RETVAL=$?

[[ $C_VERSION != $CONSUL_VERSION ]] || [[ $C_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip \
&& unzip -o consul_${CONSUL_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm consul_${CONSUL_VERSION}_linux_amd64.zip

# vault
V_VERSION=$(/usr/local/bin/vault -v)
V_RETVAL=$?

[[ $V_VERSION != $VAULT_VERSION ]] || [[ $V_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
&& unzip -o vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm vault_${VAULT_VERSION}_linux_amd64.zip


# clean up
if [ ! ${REDHAT_BASED} ] ; then
  apt-get clean
fi

