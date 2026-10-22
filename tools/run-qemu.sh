#!/bin/bash
# Boots Nimbus in QEMU. Quit with Ctrl+A then X (or "power shutdown" inside).
#   NIMBUS_KERNEL   path to a kernel image   (default: build/bzImage)
#   NIMBUS_CMDLINE  extra kernel parameters
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
kernel="${NIMBUS_KERNEL:-$root/build/bzImage}"
initrd="$root/build/initramfs.img"
disk="$root/build/rootfs.img"

for f in "$kernel" "$initrd" "$disk"; do
    [ -f "$f" ] || { echo "run-qemu: missing $f (run 'make' and 'make kernel' first)" >&2; exit 1; }
done

accel=tcg
[ -w /dev/kvm ] && accel=kvm

exec qemu-system-x86_64 \
    -accel "$accel" -cpu max -m 512M -nographic \
    -kernel "$kernel" -initrd "$initrd" \
    -drive file="$disk",format=raw,if=virtio \
    -append "root=/dev/vda rw console=ttyS0 ${NIMBUS_CMDLINE:-}"
