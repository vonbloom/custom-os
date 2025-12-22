#!/bin/bash

set -ouex pipefail

### Bootc options
mkdir -p /usr/lib/bootc/kargs.d
echo 'kargs = ["loglevel=3"]' > /usr/lib/bootc/kargs.d/00-quiet.toml

### Set language
echo "KEYMAP=es" > /etc/vconsole.conf
echo "LANG=ca_ES.UTF-8" > /etc/locale.conf

### Packages
dnf5 install -y \
    bubblewrap \
    ncurses \
    shadow-utils \
    doas \
    NetworkManager \
    glibc-langpack-ca \
    vim \
    vim-default-editor

dnf5 clean all
rm /var/{log,cache,lib}/* -rf

### Set users
echo "root:\$6\$HBBMFHo9PCNKpqjr\$scCKm1BSP60VQKSHHTHcUICdCTcY534/C09KMjNehFXhgz8OXDgVbp7iTkuLlwAqQKJ8jIKXcD07HGqs4gqRJ/" | chpasswd -e
# Desbloquejar el compte
usermod -U root
# Si fas servir SELinux (recomanat en bootc)
if [ -x /usr/sbin/restorecon ]; then
    restorecon -v /etc/shadow
fi

cp /ctx/user.conf /usr/lib/sysusers.d/roger.conf
cp /ctx/user-home.conf /usr/lib/tmpfiles.d/roger-home.conf
systemd-sysusers
echo "roger:\$6\$j80GfNM2z91f61qz\$Rn3VOL2KPPXZZNDgtvO0SQWdmArC3cmO0kSiw9MaT4TirmFr1so.GzIPz2BYbg86ob2tqXxNqWXGYZrbE7tu90" | chpasswd -e
systemd-tmpfiles --create /usr/lib/tmpfiles.d/roger-home.conf
echo "permit persist :wheel as root" > /etc/doas.conf
chmod 0400 /etc/doas.conf
echo "alias sudo='doas'" >> /etc/bashrc

# 2. Creem el directori on viurà la base immutable
# Fem servir /usr/lib perquè és un camí estàndard de sistema immutable
#mkdir -p /usr/lib/nix-base

# 3. Movem tot el contingut de /nix a la base
# Fem servir 'cp -a' per mantenir permisos, propietaris i enllaços simbòlics
#cp -aR --preserve=all /nix/* /usr/lib/nix-base/

# 4. Netegem el directori original
# L'hem de deixar buit perquè serveixi de "punt de muntatge" net
#rm -rf /nix
#mkdir -m 0755 /nix
#mkdir -p /etc/tmpfiles.d
#cp /ctx/nix-filesystem.conf /etc/tmpfiles.d/
#cp /ctx/nix.mount /usr/lib/systemd/system/

#### Example for enabling a System Unit File
systemctl enable NetworkManager
systemctl enable podman.socket
#systemctl enable nix.mount
