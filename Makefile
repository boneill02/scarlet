.POSIX:

include config.mk

LINUX_MAJOR = $(shell echo $(LINUX_VER) | cut -d'.' -f1)
BUILD_DIR = build/
ETC_DIR = etc/

all: bzImage initrd.img

bzImage:
	cd $(BUILD_DIR); \
		wget https://cdn.kernel.org/pub/linux/kernel/v$(LINUX_MAJOR).x/linux-$(LINUX_VER).tar.xz; \
		tar -xvf linux-$(LINUX_VER).tar.xz; \
		cd linux-$(LINUX_VER); \
		$(MAKE) defconfig; \
		$(MAKE)
	cp $(BUILD_DIR)/linux-$(LINUX_VER)/arch/$(ARCH)/boot/bzImage .

busybox:
	cd $(BUILD_DIR); \
		wget https://www.busybox.net/downloads/busybox-$(BUSYBOX_VER).tar.bz2; \
		tar -xvf busybox-$(BUSYBOX_VER).tar.bz2; \
		cp ../cfg/busybox-$(BUSYBOX_VER) busybox-$(BUSYBOX_VER)/.config
	cd $(BUILD_DIR)/busybox-$(BUSYBOX_VER); \
		$(MAKE)
	cp $(BUILD_DIR)/busybox-$(BUSYBOX_VER)/busybox .

initrd.img: busybox
	mkdir -p $(BUILD_DIR)/initrd
	cd $(BUILD_DIR)/initrd && mkdir -p bin dev proc sys
	cp busybox $(BUILD_DIR)/initrd/bin
	for f in $(shell ./$(BUILD_DIR)/initrd/bin/busybox --list) ; do \
		ln -s /bin/busybox $(BUILD_DIR)/initrd/bin/$$f ; \
	done
	cp -fv $(ETC_DIR)/init $(BUILD_DIR)/initrd
	chmod -R 777 $(BUILD_DIR)/initrd
	find $(BUILD_DIR)/initrd | cpio -o -H newc >initrd.img

clean:
	rm -rfv build/*
	rm -fv bzImage initrd.img busybox

run: bzImage initrd.img
	qemu-system-$(ARCH) -kernel bzImage -initrd initrd.img

.PHONY: all run
