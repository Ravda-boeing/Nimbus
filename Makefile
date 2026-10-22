# Nimbus top-level build. Run from the repo root.
#   make                   build build/initramfs.img and build/rootfs.img
#   make kernel            build the kernel and copy it to build/bzImage
#   make run               build everything and boot it in QEMU
#   make defconfig         load kernel-config/nimbus_defconfig into kernel/
#   make save-defconfig    save kernel/.config back to kernel-config/
#   make clean             delete build/

.PHONY: all initramfs rootfs kernel run defconfig save-defconfig clean

all: initramfs rootfs

initramfs:
	tools/mkinitramfs.sh

rootfs:
	tools/mkrootfs.sh

kernel:
	$(MAKE) -C kernel -j$$(nproc) bzImage
	mkdir -p build
	cp kernel/arch/x86/boot/bzImage build/bzImage

run: all
	tools/run-qemu.sh

defconfig:
	cp kernel-config/nimbus_defconfig kernel/arch/x86/configs/nimbus_defconfig
	$(MAKE) -C kernel nimbus_defconfig

save-defconfig:
	$(MAKE) -C kernel savedefconfig
	cp kernel/defconfig kernel-config/nimbus_defconfig

clean:
	rm -rf build
