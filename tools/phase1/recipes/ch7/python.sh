#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.12: Python-3.14.7
# Run as root inside the LFS chroot.
set -euo pipefail

if [ "$(id -u)" -ne 0 ] ||
   [ ! -f /sources/Python-3.14.7.tar.xz ] ||
   [ ! -x /usr/bin/gcc ]; then
    echo "python-ch7: expected root inside the LFS chroot" >&2
    exit 1
fi

mkdir -p /sources/.work /sources/.logs
work=/sources/.work/python-ch7
rm -rf "$work"
mkdir -p "$work"

exec > >(tee -a /sources/.logs/python-ch7.log) 2>&1
echo "== LFS Chapter 7.12: Python-3.14.7 =="

tar -xf /sources/Python-3.14.7.tar.xz -C "$work" --strip-components=1
cd "$work"

./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython
make
make install

echo "Python Chapter 7 build and installation completed."
