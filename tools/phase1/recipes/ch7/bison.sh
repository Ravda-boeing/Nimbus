#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.8: Bison-3.8.2
# Run as root inside the LFS chroot.
set -euo pipefail

if [ "$(id -u)" -ne 0 ] || [ ! -f /sources/bison-3.8.2.tar.xz ] || [ ! -x /usr/bin/gcc ]; then
    echo "bison-ch7: expected root inside the LFS chroot" >&2
    exit 1
fi

mkdir -p /sources/.work /sources/.logs
work=/sources/.work/bison-ch7
rm -rf "$work"
mkdir -p "$work"

exec > >(tee -a /sources/.logs/bison-ch7.log) 2>&1

echo "== LFS Chapter 7.8: Bison-3.8.2 =="
tar -xf /sources/bison-3.8.2.tar.xz -C "$work" --strip-components=1
cd "$work"

./configure --prefix=/usr \
    --docdir=/usr/share/doc/bison-3.8.2
make
make install

echo "Bison Chapter 7 build and installation completed."
