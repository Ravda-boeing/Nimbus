#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.7: Gettext-1.0
# Run as root INSIDE the LFS chroot. Do not use the Chapter 6 runner.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "gettext-ch7: must run as root inside the LFS chroot" >&2
    exit 1
fi

if [ ! -f /sources/gettext-1.0.tar.xz ] ||
   [ ! -x /usr/bin/gcc ] ||
   [ ! -x /usr/bin/make ]; then
    echo "gettext-ch7: expected LFS chroot environment not detected" >&2
    exit 1
fi

mkdir -p /sources/.work /sources/.logs
work=/sources/.work/gettext-ch7
rm -rf "$work"
mkdir -p "$work"

exec > >(tee -a /sources/.logs/gettext-ch7.log) 2>&1

echo "== LFS Chapter 7.7: Gettext-1.0 =="
tar -xf /sources/gettext-1.0.tar.xz \
    -C "$work" --strip-components=1
cd "$work"

./configure --disable-shared
make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin/

echo "Gettext Chapter 7 build and tool copy completed."
