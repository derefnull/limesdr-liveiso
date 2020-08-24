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

# Feedback

Contributions are welcome. Please contact me on github, or issue a pull request

# References

[Debian Live Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)

[Starter guide - GQRX, gnuradio3.7, soapy, gr-osmo… full working Ubuntu 18.04](https://discourse.myriadrf.org/t/starter-guide-gqrx-gnuradio3-7-soapy-gr-osmo-full-working-ubuntu-18-04/6151)

[GNURadio Install](https://wiki.gnuradio.org/index.php/UbuntuInstall)

