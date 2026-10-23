#!/bin/bash
# Nimbus Phase 1: the build disk.
# A sparse disk-image file, formatted ext4 and loop-mounted at /mnt/lfs, so the
# build never touches your real partitions or dual boot.
#
#   tools/phase1/lfs-disk.sh create [size]   make the image (default 16G), once
#   tools/phase1/lfs-disk.sh mount           mount it at /mnt/lfs (needs sudo)
#   tools/phase1/lfs-disk.sh umount          unmount it
#   tools/phase1/lfs-disk.sh status          show whether it is mounted and its usage
#
# The image is sparse: it only uses real disk space as it fills up. If the
# image fills, the build fails; if your real disk fills, the HOST is in trouble,
# so keep the size below your free space.
set -euo pipefail

IMG="${NIMBUS_BUILD_IMG:-$HOME/nimbus-build/lfs.img}"
MNT=/mnt/lfs

case "${1:-}" in
    create)
        size="${2:-16G}"
        [ -e "$IMG" ] && { echo "lfs-disk: $IMG already exists; delete it first to recreate." >&2; exit 1; }
        mkdir -p "$(dirname "$IMG")"
        truncate -s "$size" "$IMG"
        mkfs.ext4 -q -F -L LFS "$IMG"
        echo "lfs-disk: created $IMG ($size, sparse)"
        echo "Next: $0 mount"
        ;;
    mount)
        [ -f "$IMG" ] || { echo "lfs-disk: $IMG missing; run '$0 create' first." >&2; exit 1; }
        if mountpoint -q "$MNT"; then echo "lfs-disk: already mounted at $MNT"; exit 0; fi
        sudo mkdir -p "$MNT"
        sudo mount -o loop "$IMG" "$MNT"
        echo "lfs-disk: mounted at $MNT"
        echo "In every shell you use for the build:  export LFS=$MNT"
        ;;
    umount)
        mountpoint -q "$MNT" || { echo "lfs-disk: not mounted"; exit 0; }
        sudo umount "$MNT"
        echo "lfs-disk: unmounted"
        ;;
    status)
        if mountpoint -q "$MNT"; then df -h "$MNT"; else echo "not mounted ($IMG: $(du -h "$IMG" 2>/dev/null | cut -f1) used on disk)"; fi
        ;;
    *)
        sed -n '2,12p' "$0"; exit 1
        ;;
esac
