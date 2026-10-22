#!/bin/bash
# Builds build/initramfs.img from initramfs/
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
build="$root/build"
stage="$build/initramfs"

command -v cpio >/dev/null || { echo "mkinitramfs: cpio not installed (sudo apt install cpio)" >&2; exit 1; }

rm -rf "$stage"
mkdir -p "$stage"
cp -a "$root/initramfs/." "$stage/"
mkdir -p "$stage"/{dev,proc,sys,mnt,tmp,etc}
chmod +x "$stage/init"

"$root/tools/link-applets.sh" "$stage"

( cd "$stage" && find . | sort | cpio -o -H newc --quiet | gzip -9 ) > "$build/initramfs.img"
echo "mkinitramfs: wrote build/initramfs.img ($(du -h "$build/initramfs.img" | cut -f1))"
