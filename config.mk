.POSIX:

ARCH = x86_64
LINUX_VER = 6.0.9
LINUX_MAJOR = $(shell echo $LINUX_VER | cut -d'.' -f1)
BUSYBOX_VER = 1.35.0
CC = ${ARCH}-linux-musl-gcc
BUILD_DIR = build/
ETC_DIR = etc/
