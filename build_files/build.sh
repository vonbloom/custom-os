#!/bin/bash

set -ouex pipefail

### Set users
useradd -m -G wheel roger
echo "root:\$6\$HBBMFHo9PCNKpqjr\$scCKm1BSP60VQKSHHTHcUICdCTcY534/C09KMjNehFXhgz8OXDgVbp7iTkuLlwAqQKJ8jIKXcD07HGqs4gqRJ/" | chpasswd -e
echo "roger:\$6\$j80GfNM2z91f61qz\$Rn3VOL2KPPXZZNDgtvO0SQWdmArC3cmO0kSiw9MaT4TirmFr1so.GzIPz2BYbg86ob2tqXxNqWXGYZrbE7tu90" | chpasswd -e
echo 'roger ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/roger

### Bootc options
mkdir -p /usr/lib/bootc/kargs.d
echo 'kargs = ["loglevel=3"]' > /usr/lib/bootc/kargs.d/00-quiet.toml

### Set language
echo "KEYMAP=es" > /etc/vconsole.conf
echo "LANG=ca_ES.UTF-8" > /etc/locale.conf

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this removes packages
dnf5 remove -y nano nano-default-editor "qemu-user-static*"
rm -f /usr/lib/binfmt.d/qemu-*

# this installs package from fedora repos
dnf5 install -y \
    NetworkManager-wifi \
    iwlwifi-mvm-firmware \
    glibc-langpack-ca \
    nix \
    vim-default-editor
    #amd-gpu-firmware \
    #amd-ucode-firmware \

dnf5 clean all

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### Set nix path
mkdir -p /var/nix
if [ -d /nix ]; then
    cp -a /nix/. /var/nix/ || true
    rm -rf /nix
fi
ln -s /var/nix /nix

#### Example for enabling a System Unit File

systemctl enable NetworkManager
systemctl enable podman.socket
