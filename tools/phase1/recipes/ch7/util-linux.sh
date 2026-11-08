#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.14: Util-linux-2.42.2
# Run as root inside the LFS chroot.
set -euo pipefail

if [ "$(id -u)" -ne 0 ] ||
   [ ! -f /sources/util-linux-2.42.2.tar.xz ] ||
   [ ! -x /usr/bin/gcc ]; then
    echo "util-linux-ch7: expected root inside the LFS chroot" >&2
    exit 1
fi

mkdir -p /sources/.work /sources/.logs
work=/sources/.work/util-linux-ch7
rm -rf "$work"
mkdir -p "$work"

exec > >(tee -a /sources/.logs/util-linux-ch7.log) 2>&1

echo "== LFS Chapter 7.14: Util-linux-2.42.2 =="

tar -xf /sources/util-linux-2.42.2.tar.xz -C "$work" --strip-components=1
cd "$work"

mkdir -pv /var/lib/hwclock

./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.42.2

make
make install

echo "Util-linux Chapter 7 build and installation completed."
