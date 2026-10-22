# kernel-config

`nimbus_defconfig` is the Nimbus kernel configuration, saved as a minimal
defconfig (only the options that differ from the defaults).

- Load it:  `make defconfig`
- Save it after changing options in `kernel/`:  `make save-defconfig`

Needed built in (=y), because Nimbus does not load modules yet:
BLK_DEV_INITRD, DEVTMPFS, DEVTMPFS_MOUNT, EXT4_FS, VIRTIO_BLK,
SERIAL_8250_CONSOLE.
