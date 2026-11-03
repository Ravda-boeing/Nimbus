#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.10: Zlib-1.3.2
# Run as root inside the LFS chroot.
set -euo pipefail

if [ "$(id -u)" -ne 0 ] ||
   [ ! -f /sources/zlib-1.3.2.tar.gz ] ||
   [ ! -x /usr/bin/gcc ]; then
    echo "zlib-ch7: expected root inside the LFS chroot" >&2
    exit 1
fi

mkdir -p /sources/.work /sources/.logs
work=/sources/.work/zlib-ch7
rm -rf "$work"
mkdir -p "$work"

exec > >(tee -a /sources/.logs/zlib-ch7.log) 2>&1
echo "== LFS Chapter 7.10: Zlib-1.3.2 =="

tar -xf /sources/zlib-1.3.2.tar.gz -C "$work" --strip-components=1
cd "$work"

./configure --prefix=/usr
make
make install
rm -fv /usr/lib/libz.a

echo "Zlib Chapter 7 build and installation completed."
