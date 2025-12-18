#!/bin/bash

set -ouex pipefail

### Set users
useradd -m -G wheel roger
echo "root:\$6\$MKg6cGNyAXu4pqcM\$DOVdXJ4SIPeDtsaMf8DK3mvJzuvUCALLESWLWbdTwKLq58tY2mg8sRR9W1k3yLohj69afFtc/jtGG9qolpddF." | chpasswd -e
echo "roger:\$6\$j80GfNM2z91f61qz\$Rn3VOL2KPPXZZNDgtvO0SQWdmArC3cmO0kSiw9MaT4TirmFr1so.GzIPz2BYbg86ob2tqXxNqWXGYZrbE7tu90" | chpasswd -e
echo 'roger ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/roger

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y NetworkManager-wifi iwlwifi-mvm-firmware linux-firmware

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable NetworkManager
systemctl enable podman.socket
