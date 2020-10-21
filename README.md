# LimeSDR LiveISO

Debian Live is used to create a BIOS/UEFI compatible Live USB bootable disk complete with LimeSDR, Gqrx, GnuRadio softwares.

The build approach is nested:

1. Chroot into a fresh debian 'buster' environment
   - add live build tooling
2. Create a 'live build' 'buster' environment
   - add development packages
   - download github repositories
   - build/install into the livebuild chroot
3. Complete the 'live build' build to ISO
4. Boot the iso

# Building faster

Use a local package cache [apt-cacher-ng](https://www.unix-ag.uni-kl.de/~bloch/acng/html/index.html) to keep most of your build development off the network

# VirtualBox Support

Facilitating running this ISO in a virtualbox virtual machine, this variant of ISO pre-installs [VirtualBox Guest Additions](https://www.oracle.com/virtualization/technologies/vm/downloads/virtualbox-downloads.html)

# Feedback

Contributions are welcome. Please contact me on github, or issue a pull request

# References

[Debian Live Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)

[Starter guide - GQRX, gnuradio3.7, soapy, gr-osmo… full working Ubuntu 18.04](https://discourse.myriadrf.org/t/starter-guide-gqrx-gnuradio3-7-soapy-gr-osmo-full-working-ubuntu-18-04/6151)

[GNURadio Install](https://wiki.gnuradio.org/index.php/UbuntuInstall)

[Building VirtualBox](https://www.virtualbox.org/wiki/Linux%20build%20instructions)
https://download.virtualbox.org/virtualbox/6.1.14/

[VirtualBox Licensing FAQ](https://www.virtualbox.org/wiki/Licensing_FAQ)

[Ubuntu Live Build](https://wiki.ubuntu.com/Live-Build) check out running the iso in qemu-kvm
