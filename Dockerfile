FROM ubuntu

# Prerequisities
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    lsb-release \
    openssh-client \
    gnupg2 \
    unzip \
    curl \
    jq \
    wget \
    software-properties-common \
    git \
    rsync

# QEMU
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends qemu-kvm ebtables libguestfs-tools

# Packer
RUN PACKER_VERSION=$(wget -O- https://releases.hashicorp.com/packer/ 2> /dev/null \
      | sed -r -e 's/.*packer_([0-9]+\.[0-9]+\.[0-9]+)<\/a>.*/\1/' -e '/^[0-9]+\.[0-9]+\.[0-9]+$/!d' \
      | sort --version-sort --reverse \
      | head -n 1) && \
    wget -q -O packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer.zip && \
    chmod +x packer && \
    mv packer /usr/local/bin && \
    rm packer.zip

# Openstack-cli
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-openstackclient s3cmd zip

# Ansible
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip && pip3 install ansible pywinrm --break-system-packages

# Tofu
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && \
    chmod +x install-opentofu.sh && \
    ./install-opentofu.sh --install-method standalone && \
    rm ./install-opentofu.sh

# UEFI disk tools and TPM support for building new Windows images
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ovmf \
    swtpm \
    swtpm-tools \
    gdisk \
    parted

# Vault
RUN VAULT_VERSION=$(curl -s https://releases.hashicorp.com/vault/index.json | jq -r '.versions | keys[] | select(. | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' | sort -V | tail -1) \
    && curl -sSL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip \
    && unzip vault.zip -d /usr/local/bin/ \
    && rm vault.zip \
    && chmod +x /usr/local/bin/vault

RUN apt-get -y clean
