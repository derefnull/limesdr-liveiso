#!/bin/bash

#
# references:
#  https://discourse.myriadrf.org/t/starter-guide-gqrx-gnuradio3-7-soapy-gr-osmo-full-working-ubuntu-18-04/6151
#  https://wiki.gnuradio.org/index.php/UbuntuInstall#Bionic_Beaver_.2818.04.29_through_Eoan_Ermine_.2819.10.29
#

SUITE=buster
PATH_OUTPUT=output/$SUITE-iso

echo Installing debootstrap
sudo apt-get install debootstrap

# Step 1. Create a fresh debian chroot within which to install live-build
mkdir -p $PATH_OUTPUT
sudo debootstrap $SUITE $PATH_OUTPUT

# Step 2. Create the live-build bootstrap script
cat <<EOF > tmp_bootstrap.sh
#!/bin/bash

PATH_ISO=/iso

mkdir -p \$PATH_ISO
apt-get install -y live-build

cd \$PATH_ISO
lb config -d $SUITE --debian-installer live

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



cat << PKG_EOF > config/package-lists/build.list.chroot
autoconf
automake
bison
cmake
doxygen
ffmpeg
fftw3-dev
flex
freeglut3-dev
g++
git
graphviz
libasound2-dev
libavcodec-dev
libavformat-dev
libboost-all-dev
libczmq-dev
libfftw3-dev
libgmp-dev
libi2c-dev
liblog4cpp5-dev
libopencv-dev
libopus-dev
libpulse-dev
libpython-dev
libqt5multimedia5-plugins
libqt5opengl5-dev
libqt5svg5-dev
libqt5websockets5-dev
libqwt-qt5-dev
libsamplerate0-dev
libsqlite3-dev
libspeexdsp-dev 
libtool
libusb-1.0-0
libusb-1.0-0-dev
libusb-dev
libwxgtk3.0-dev
libxml2-dev
pkg-config
pulseaudio
pybind11-dev
python-numpy
python3
python3-click
python3-click-plugins
python3-gi-cairo
python3-lxml
python3-mako
python3-numpy
python3-pip
python3-pyqt5
python3-scipy
python3-sphinx
python3-yaml
python3-zmq
qt5-default
qtbase5-dev
qtchooser
qtmultimedia5-dev
qttools5-dev
qttools5-dev-tools
swig
wget
PKG_EOF

# Add a script to compile LimeSuite tooling
cat << LS_EOF > config/hooks/normal/limesuite.hook.chroot
#!/bin/bash
set -e

LIME_SRC=/build
LIME_INSTALL=

mkdir \\\$LIME_SRC -p

#
# Prepare the build directory
#
cd \\\$LIME_SRC
git clone https://github.com/myriadrf/LimeSuite.git
git clone https://github.com/pothosware/SoapySDR.git
git clone --recursive https://github.com/pothosware/PothosCore.git
git clone https://github.com/gnuradio/volk.git
git clone --recursive https://github.com/gnuradio/gnuradio.git #follwing https://wiki.gnuradio.org/index.php/InstallingGR#Notes
git clone https://github.com/osmocom/rtl-sdr.git
git clone https://git.osmocom.org/gr-osmosdr
git clone https://github.com/csete/gqrx.git
#git clone git://git.osmocom.org/sdrangelove.git

function buildit() {
  echo building \\\$1
  mkdir -p \\\$LIME_SRC/output_\\\$1
  cmake -S \\\$LIME_SRC/\\\$1 -B \\\$LIME_SRC/output_\\\$1 -DCMAKE_INSTALL_PREFIX=\\\$LIME_INSTALL -DCMAKE_PREFIX_PATH=\\\$LIME_INSTALL
  make -j\\\$(nproc --all) -C \\\$LIME_SRC/output_\\\$1
  make -C \\\$LIME_SRC/output_\\\$1 install
}

function build_gnr() {
  cd \\\$LIME_SRC/gnuradio && git checkout maint-3.8
  # cd \\\$LIME_SRC/gnuradio && git pull --recurse-submodules=on && git submodule update --init
  mkdir -p \\\$LIME_SRC/gnuradio/build
  cmake -S \\\$LIME_SRC/gnuradio -B \\\$LIME_SRC/gnuradio/build -DENABLE_INTERNAL_VOLK=OFF -DENABLE_GR_UHD=OFF -DENABLE_GR_FFT=ON -DCMAKE_INSTALL_PREFIX=\\\$LIME_INSTALL -DCMAKE_PREFIX_PATH=\\\$LIME_INSTALL
  make -j\\\$(nproc --all) -C \\\$LIME_SRC/gnuradio/build
  make install -C \\\$LIME_SRC/gnuradio/build
  cd \\\$LIME_SRC
}


#
# Build the projects! 
#
cd \\\$LIME_SRC
buildit SoapySDR
buildit LimeSuite
buildit PothosCore
buildit rtl-sdr
buildit volk
build_gnr
buildit gr-osmosdr
buildit gqrx
#buildit sdrangelove

# Build SDRAngel

# CM265cc
cd \\\$LIME_SRC
git clone https://github.com/f4exb/cm256cc.git
cd cm256cc
git reset --hard c0e92b92aca3d1d36c990b642b937c64d363c559
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=\\\$LIME_INSTALL ..
make -j \\\$(nproc --all) install

# MBElib
cd \\\$LIME_SRC
git clone https://github.com/szechyjs/mbelib.git
cd mbelib
git reset --hard 9a04ed5c78176a9965f3d43f7aa1b1f5330e771f
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=\\\$LIME_INSTALL ..
make -j \\\$(nproc --all) install

# SerialDV
cd \\\$LIME_SRC
git clone https://github.com/f4exb/serialDV.git
cd serialDV
git reset --hard "v1.1.4"
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=\\\$LIME_INSTALL ..
make -j \\\$(nproc --all) install

# DSDcc
cd \\\$LIME_SRC
git clone https://github.com/f4exb/dsdcc.git
cd dsdcc
git reset --hard "v1.9.0"
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=\\\$LIME_INSTALL -DUSE_MBELIB=ON ..
make -j \\\$(nproc --all) install

# Codec2/FreeDV
cd \\\$LIME_SRC
git clone https://github.com/drowe67/codec2.git
cd codec2
git reset --hard 76a20416d715ee06f8b36a9953506876689a3bd2
mkdir build_linux; cd build_linux
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=\\\$LIME_INSTALL ..
make -j \\\$(nproc --all) install

# SDRAngel
cd \\\$LIME_SRC
git clone https://github.com/f4exb/sdrangel.git
cd sdrangel
mkdir build; cd build
cmake -Wno-dev -DDEBUG_OUTPUT=ON -DRX_SAMPLE_24BIT=ON -DCMAKE_INSTALL_PREFIX=\\\$LIME_INSTALL ..
make -j \\\$(nproc --all) install


cat << UDEV_EOF > /etc/udev/rules.d/64-limesuite.rules
# https://github.com/myriadrf/LimeSuite/blob/master/udev-rules/64-limesuite.rules
SUBSYSTEM=="usb", ATTR{idVendor}=="04b4", ATTR{idProduct}=="8613", SYMLINK+="stream-%k", MODE="666"
SUBSYSTEM=="usb", ATTR{idVendor}=="04b4", ATTR{idProduct}=="00f1", SYMLINK+="stream-%k", MODE="666"
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="601f", SYMLINK+="stream-%k", MODE="666"
SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="6108", SYMLINK+="stream-%k", MODE="666"
SUBSYSTEM=="xillybus", MODE="666", OPTIONS="last_rule"
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", SYMLINK+="serial"
UDEV_EOF

rm /build -rf

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

