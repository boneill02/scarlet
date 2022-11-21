# Scarlet Linux

Configuration files and scripts for building a tiny Linux + Busybox
distribution. Intended for use as a recovery OS in BIOS chips on Libreboot-supported
devices.

Currently, the build script will create a kernel and initrd with the default
configurations for both Linux and Busybox. This runs, however it is around ~14MB
total. In order to store on a ROM chip on one of these systems, the total size
must be anywhere between 2MB and 10MB. In order to achieve this, certain
unnecessary Busybox programs and Linux drivers must be disabled (not currently
supported).

[This video](https://youtu.be/asnXWOUKhTA) has been very helpful in the initial
setup.
