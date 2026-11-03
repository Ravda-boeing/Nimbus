#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.11: mpdecimal-4.0.1
# Run as root inside the LFS chroot.
set -euo pipefail

if [ "$(id -u)" -ne 0 ] ||
   [ ! -f /sources/mpdecimal-4.0.1.tar.gz ] ||
   [ ! -x /usr/bin/gcc ]; then
    echo "mpdecimal-ch7: expected root inside the LFS chroot" >&2
    exit 1
fi

mkdir -p /sources/.work /sources/.logs
work=/sources/.work/mpdecimal-ch7
rm -rf "$work"
mkdir -p "$work"

exec > >(tee -a /sources/.logs/mpdecimal-ch7.log) 2>&1
echo "== LFS Chapter 7.11: mpdecimal-4.0.1 =="

tar -xf /sources/mpdecimal-4.0.1.tar.gz -C "$work" --strip-components=1
cd "$work"

./configure --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/mpdecimal-4.0.1
make
make install

echo "mpdecimal Chapter 7 build and installation completed."
