#!/bin/bash

#
# references:
#
# https://www.virtualbox.org/wiki/Linux%20build%20instructions)
#

SUITE=buster
PATH_OUTPUT=output/$SUITE-iso

echo Installing debootstrap
sudo apt-get install debootstrap apt-cacher-ng

# Step 1. Create a fresh debian chroot within which to install live-build
mkdir -p $PATH_OUTPUT
sudo debootstrap $SUITE $PATH_OUTPUT http://localhost:3142/ftp.debian.org/debian

# Step 2. Create the live-build bootstrap script
cat <<EOF > tmp_bootstrap.sh
#!/bin/bash

PATH_ISO=/iso

mkdir -p \$PATH_ISO
apt-get install -y live-build

cd \$PATH_ISO
lb config -d $SUITE --debian-installer live --mirror-bootstrap http://localhost:3142/ftp.debian.org/debian 

echo "deb http://localhost:3142/ftp.debian.org/debian buster-backports main" > config/archives/debian-backports.list.chroot

# be sure to install a GUI
cat << GUI_EOF > config/package-lists/gui.list.chroot
xterm
gdm3
menu 
gnome-session
gnome-panel
mutter
gnome-terminal
GUI_EOF

# Add a script to include VirtualBox Guest Additions
cat << LS_EOF > config/hooks/normal/guest-additions.hook.chroot
#!/bin/bash
set -e

apt-get install -y build-essential dkms linux-headers-amd64

apt-get install -y acpica-tools chrpath doxygen g++-multilib libasound2-dev libcap-dev \\
        libcurl4-openssl-dev libdevmapper-dev libidl-dev libopus-dev libpam0g-dev \\
        libpulse-dev libqt5opengl5-dev libqt5x11extras5-dev libsdl1.2-dev libsdl-ttf2.0-dev \\
        libssl-dev libvpx-dev libxcursor-dev libxinerama-dev libxml2-dev libxml2-utils \\
        libxmu-dev libxrandr-dev make nasm python3-dev python-dev qttools5-dev-tools \\
        texlive texlive-fonts-extra texlive-latex-extra unzip xsltproc \\
        \\
        default-jdk libstdc++5 libxslt1-dev linux-kernel-headers makeself \\
        mesa-common-dev subversion yasm zlib1g-dev
apt-get install -y lib32z1 libc6-dev-i386 lib32gcc1 lib32stdc++6
apt-get install -y wget
apt-get install -y linux-headers-5.8.0-0.bpo.2-amd64 linux-image-5.8.0-0.bpo.2-amd64

kernel_version=5.8.0-0.bpo.2-amd64

# Stage guest-additions
vbox_dl_version=6.1.14a
vbox_dir_version=6.1.14
wget http://localhost:3142/download.virtualbox.org/virtualbox/\\\$vbox_dir_version/VirtualBox-\\\$vbox_dl_version.tar.bz2 -O /tmp/VirtualBox-\\\$vbox_dl_version.tar.bz2
tar -xjf /tmp/VirtualBox-\\\$vbox_dl_version.tar.bz2 -C /

cd /VirtualBox-\\\$vbox_dir_version
./configure 
source ./env.sh
kmk VBOX_ONLY_ADDITIONS=1
cd ./out/linux.amd64/release/bin/additions/src
make install KERN_VER=\\\$kernel_version

apt-get remove -y build-essential dkms linux-headers-amd64
apt-get remove -y acpica-tools chrpath doxygen g++-multilib libasound2-dev libcap-dev \\
        libcurl4-openssl-dev libdevmapper-dev libidl-dev libopus-dev libpam0g-dev \\
        libpulse-dev libqt5opengl5-dev libqt5x11extras5-dev libsdl1.2-dev libsdl-ttf2.0-dev \\
        libssl-dev libvpx-dev libxcursor-dev libxinerama-dev libxml2-dev libxml2-utils \\
        libxmu-dev libxrandr-dev make nasm python3-dev python-dev qttools5-dev-tools \\
        texlive texlive-fonts-extra texlive-latex-extra unzip xsltproc \\
        \\
        default-jdk libstdc++5 libxslt1-dev linux-kernel-headers makeself \\
        mesa-common-dev subversion yasm zlib1g-dev
apt-get autoremove -y
rm -rf /VirtualBox-\\\$vbox_dir_version /tmp/VirtualBox-\\\$vbox_dl_version.tar.bz2

LS_EOF


lb build 2>&1 | tee /tmp/build.log

EOF

# Step 3. Run the chrooted live-build bootstrap script
sudo mv tmp_bootstrap.sh $PATH_OUTPUT/bootstrap.sh
sudo chmod +x $PATH_OUTPUT/bootstrap.sh

sudo mount --bind /dev $PATH_OUTPUT/dev
sudo mount -t proc proc $PATH_OUTPUT/proc
sudo mount -t sysfs sysfs $PATH_OUTPUT/sys

sudo chroot $PATH_OUTPUT /bootstrap.sh

sudo umount $PATH_OUTPUT/dev
sudo umount $PATH_OUTPUT/proc
sudo umount $PATH_OUTPUT/sys

