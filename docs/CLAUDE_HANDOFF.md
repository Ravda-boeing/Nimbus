# Nimbus handoff for Claude

Prepared 2026-11-21 for continuing work in `/home/reheni/Nimbus`.

## Project goal

Nimbus is a from-scratch Linux distribution. The long-term aim is a daily-usable desktop OS in the spirit of Linux Mint. Phase 0 is a small BusyBox-based Nimbus system booting in QEMU. Phase 1 builds the LFS base system from source, using systemd and Nimbus's Bash package manager, npskg. The present goal is to get the LFS system booting under QEMU, then on the USB NIMBUS partition, and only after that on the internal NVMe disk.

## Sources of truth

- Follow the current LFS systemd book at <https://linuxfromscratch.org/lfs/view/systemd/>. The current Chapter 10 kernel page is revision r13.1-32 and uses Linux 7.3. The fixed 13.1 release page is older and uses Linux 7.1.8.
- Read `docs/PHASE1.md` before operating on `/mnt/lfs`. It documents remount/recovery and chroot safety.
- Use `docs/UPDATELOG.md` for dated work and failure history.
- Chapter 9 configuration is in `docs/CHAPTER9.md`; its read-only checker is `tools/phase1/check-chapter9.sh`.
- Package format and manager: `docs/PACKAGES.md` and `tools/npskg/npskg`.

## Completed work

- Phase 0 boots and shuts down in QEMU with BusyBox.
- LFS Chapters 5–7 are complete. Chapter 8 is complete: all 81 package recipes are installed according to the latest reports, including Findutils 4.11.0 and GRUB 2.14. Verify the live npskg database before relying on that count.
- Chapter 9 configuration is applied and verified: host name Nimbus, wired DHCP with systemd-networkd, systemd-resolved, `en_AU.UTF-8`, US keymap, Melbourne timezone, UTC RTC, hosts, profile, inputrc, and shells.
- Linux 7.3.0 was built in the LFS chroot using `kernel-config/nimbus_defconfig`, with `CONFIG_BLK_DEV_NVME=y` added. EFI, EFI stub, EFI partition, VFAT, ext4, devtmpfs, VirtIO block, and serial console support are enabled. Installed files: `/boot/vmlinuz-7.3-nimbus`, `/boot/System.map-7.3`, `/boot/config-7.3`; modules under `/lib/modules/7.3.0`.
- Added `/etc/fstab` to the LFS root with ext4 UUID `a153e3e4-fc25-4aca-addc-3276857bfcbe` and pseudo-filesystem entries.
- Backed up the 30 GiB LFS image to the USB NIMBUS partition as `lfs-before-chapter10.img.zst` (6.1 GiB); `zstd -t` passed. USB was unmounted after the backup.
- Installed QEMU on the host and booted the LFS image directly as a VirtIO disk using `root=/dev/vda` and the Linux 7.3 kernel. `root=UUID=...` did not work without an initramfs. The LFS system reaches `multi-user.target` and accepts root login.
- Set a known root password from inside chroot with chroot support mounts active.
- Found D-Bus was not started at boot, so logind failed. Added `/etc/systemd/system/dbus.service` in the LFS image with `Type=simple`, `ExecStartPre=/usr/bin/mkdir -p /run/dbus`, and `ExecStart=/usr/bin/dbus-daemon --system --nofork --nopidfile`, enabled for `basic.target`. Added `/etc/systemd/system/systemd-logind.service.d/dbus.conf` requiring and ordering after `dbus.service`. After reboot, both dbus.service and systemd-logind.service are active and logind created seat0.
- D-Bus emits an `org.freedesktop.systemd1` activation warning because its service descriptor intentionally contains `Exec=/bin/false`; do not replace that guard with another systemd process. Investigate later if needed; D-Bus and logind were active despite the warning.

## Current runtime and next steps

The user is logged into the LFS system in QEMU as root. QEMU boot command used on the host:

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -m 1G \
  -nographic \
  -kernel build/vmlinuz-7.3-nimbus \
  -drive file=/home/reheni/nimbus-build/lfs.img,format=raw,if=virtio \
  -append 'root=/dev/vda rw console=ttyS0 systemd.unit=multi-user.target'
```

Next:

1. Create a regular `nimbus` user and set its password inside QEMU, then verify it can log in. The old `nimbus`/`os` credentials belong to the BusyBox prototype and do not exist in the LFS root.
2. Shut down QEMU cleanly. On the host, make sure the image is unmounted before any filesystem check or copy.
3. Prepare the USB NIMBUS partition as the next boot target. Identify the partition layout and decide where its boot files/EFI System Partition live before running `grub-install`. Do not touch the laptop's internal EFI partition or NVMe bootloader during the USB stage.
4. Test USB boot. Only after it succeeds should the NVMe installation be planned.
5. Record changes in `docs/UPDATELOG.md`, then reconcile older status text in README/DESIGN/PHASE1 as appropriate.

## Important environment facts

- Current host: Lenovo ThinkBook 14 IML, Intel i7-10510U (4 cores/8 logical CPUs), Ubuntu-based host. Use all 8 logical CPUs only when requested; the earlier regular build preference was 2 cores/4 threads.
- Current LFS image path: `/home/reheni/nimbus-build/lfs.img`, 30 GiB sparse ext4 image, normally mounted at `/mnt/lfs`.
- Image UUID: `a153e3e4-fc25-4aca-addc-3276857bfcbe`.
- USB disk seen in recent `lsblk`: `/dev/sda`, NIMBUS ext4 partition `/dev/sda2` (UUID `c23aafce-e1fd-48d0-8fc3-72845ea67915`); internal EFI is `/dev/nvme0n1p1`. Re-check device names before acting because they can change.
- To remount for chroot work: `tools/phase1/lfs-disk.sh mount`, `export LFS=/mnt/lfs`, `tools/phase1/chroot.sh mount`. To unmount, run `tools/phase1/chroot.sh umount` then `tools/phase1/lfs-disk.sh umount`.
- QEMU exits with Ctrl+A then X if needed. Prefer `systemctl poweroff` from the guest for a clean shutdown.

## Git state at handoff

The Chapter 9 docs/checker, Chapter 8 Findutils updates and GRUB recipe adjustment have been committed in the preceding commits. The GRUB adjustment excludes the shared `/usr/share/info/dir` file owned by Glibc. This handoff and the latest QEMU progress log are being committed now. Check `git status` and recent history after checkout.
