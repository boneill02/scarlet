#!/bin/sh

ARCH="x86_64"
CC="$ARCH-linux-musl-gcc"
LINUX_VER=6.0.9
BUSYBOX_VER=1.35.0
LINUX_MAJOR=$(echo $LINUX_VER | cut -d'.' -f1)
MAKEFLAGS="CC=$CC -j8"

build_dir="$(pwd)/build"
cfg_dir="$(pwd)/cfg"

linux_build() {
	wget https://cdn.kernel.org/pub/linux/kernel/v$LINUX_MAJOR.x/linux-$LINUX_VER.tar.xz
	tar -xvf linux-$LINUX_VER.tar.xz
	cd linux-$LINUX_VER
	cp $cfg_dir/linux-$LINUX_VER .config
	make $MAKEFLAGS || exit
	cp arch/x86_64/boot/bzImage ..
	cd ..
}

busybox_build() {
	wget https://www.busybox.net/downloads/busybox-$BUSYBOX_VER.tar.bz2
	tar -xvf busybox-$BUSYBOX_VER.tar.bz2
	cd busybox-$BUSYBOX_VER
	cp $cfg_dir/linux-$LINUX_VER .config
	make $MAKEFLAGS || exit
	cd ..
}

initrd_setup() {
	mkdir initrd
	cd initrd
	mkdir -p bin dev proc sys
	cd bin
	pwd
	cp ../../busybox-$BUSYBOX_VER/busybox .
	for f in $(./busybox --list); do
		ln -s /bin/busybox $f
	done
	cd ..

	cat > init <<EOF
#!/bin/sh
mount -t sysfs sysfs /sys
mount -t proc proc /proc
mount -t devtmpfs udev /dev
sysctl -w kernel.printk="2 4 1 7"
clear
/bin/sh
EOF
	chmod -R 777 .
	find . | cpio -o -H newc >../initrd.img
	cd ..
}

run() {
	qemu-system-$ARCH -kernel bzImage -initrd initrd.img
}

mkdir -p $build_dir
cd $build_dir
linux_build
busybox_build
initrd_setup
