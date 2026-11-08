#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.13: Texinfo-7.3
# Run as root inside the LFS chroot.
set -euo pipefail

if [ "$(id -u)" -ne 0 ] ||
   [ ! -f /sources/texinfo-7.3.tar.xz ] ||
   [ ! -x /usr/bin/gcc ]; then
    echo "texinfo-ch7: expected root inside the LFS chroot" >&2
    exit 1
fi

mkdir -p /sources/.work /sources/.logs
work=/sources/.work/texinfo-ch7
rm -rf "$work"
mkdir -p "$work"

exec > >(tee -a /sources/.logs/texinfo-ch7.log) 2>&1
echo "== LFS Chapter 7.13: Texinfo-7.3 =="

tar -xf /sources/texinfo-7.3.tar.xz -C "$work" --strip-components=1
cd "$work"

./configure --prefix=/usr
make
make install

echo "Texinfo Chapter 7 build and installation completed."
