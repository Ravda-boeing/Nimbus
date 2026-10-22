#!/bin/bash
# Builds build/rootfs.img (a bare ext4 filesystem) from rootfs/
# No root needed. Size can be changed with NIMBUS_ROOTFS_SIZE (default 64M).
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
build="$root/build"
stage="$build/rootfs"

command -v mke2fs >/dev/null || { echo "mkrootfs: mke2fs not installed (sudo apt install e2fsprogs)" >&2; exit 1; }

rm -rf "$stage"
mkdir -p "$stage"
cp -a "$root/rootfs/." "$stage/"

# directories git can't track because they're empty
mkdir -p "$stage"/{dev,proc,sys,tmp,run,mnt,root,home,var/log}
chmod 1777 "$stage/tmp"
chmod 700 "$stage/root"

"$root/tools/link-applets.sh" "$stage"

rm -f "$build/rootfs.img"
mke2fs -q -t ext4 -F -d "$stage" -E root_owner=0:0 "$build/rootfs.img" "${NIMBUS_ROOTFS_SIZE:-64M}"
echo "mkrootfs: wrote build/rootfs.img"
