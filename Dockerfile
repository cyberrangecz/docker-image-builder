FROM ubuntu:20.04

# Prerequisities
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y tzdata --no-install-recommends && apt-get install -y --no-install-recommends \
    ca-certificates \
    lsb-release \
    openssh-client \
    gnupg2 \
    unzip \
    curl \
    jq \
    wget \
    software-properties-common \
    xvfb \
    git \
    libarchive-tools

# QEMU
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends qemu-kvm ebtables libguestfs-tools

# Virtualbox
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y linux-headers-generic virtualbox

RUN VIRTUALBOX_VERSION=`VBoxManage --version | sed -r -e '/[0-9]+\.[0-9]+\.[0-9]+/!d' -e 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/'` && \
    wget -q https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/Oracle_VM_VirtualBox_Extension_Pack-${VIRTUALBOX_VERSION}.vbox-extpack && \
    echo "y" | VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-${VIRTUALBOX_VERSION}.vbox-extpack && \
    rm Oracle_VM_VirtualBox_Extension_Pack-${VIRTUALBOX_VERSION}.vbox-extpack && \
    VBoxManage setproperty vrdeextpack "Oracle VM VirtualBox Extension Pack"

# Packer
RUN PACKER_VERSION=`wget -O- https://releases.hashicorp.com/packer/ 2> /dev/null \
      | fgrep '/packer' \
      | head -1 \
      | sed -r 's/.*packer_([0-9.]+).*/\1/'` && \
    wget -q -O packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer.zip && \
    chmod +x packer && \
    mv packer /usr/local/bin && \
    rm packer.zip

# Vagrant
RUN VAGRANT_VERSION=`wget -O- https://releases.hashicorp.com/vagrant/ 2> /dev/null \
      | fgrep '/vagrant' \
      | head -1 \
      | sed -r 's/.*vagrant_([0-9.]+).*/\1/'` && \
    wget -q -O vagrant.zip https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_linux_amd64.zip && \
    unzip vagrant.zip && \
    chmod +x vagrant && \
    mv vagrant /usr/local/bin && \
    rm vagrant.zip

# Openstack-cli
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-openstackclient

# Ansible
#RUN apt-add-repository --yes --update ppa:ansible/ansible
#RUN apt-get install -y ansible
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip && pip3 install ansible

RUN apt-get -y clean
