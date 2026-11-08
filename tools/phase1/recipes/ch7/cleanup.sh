#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.15: Cleaning up (section "Cleaning" only)
# Run as root inside the LFS chroot. THIS SCRIPT DELETES FILES: it refuses to run
# anywhere except inside the chroot.
#
# Commands taken from the LFS 12.4 (7.13) cleanup page and the book's development
# source; the 13.1 page itself has not been compared yet. The 13.1 book numbers
# this section 7.15 (13.1 PDF table of contents).
# The optional "Backup" part of that section is not done here: the build image
# is backed up from the host (gzip of lfs.img) before this runs.
set -euo pipefail

# 1. Must be root.
if [ "$(id -u)" -ne 0 ]; then
    echo "cleanup-ch7: must run as root inside the LFS chroot" >&2
    exit 1
fi

# 2. Must really be inside a chroot: our / must differ from PID 1's root.
here=$(stat -c %d:%i / 2>/dev/null || true)
init=$(stat -c %d:%i /proc/1/root/. 2>/dev/null || true)
if [ -z "$here" ] || [ -z "$init" ] || [ "$here" = "$init" ]; then
    echo "cleanup-ch7: cannot confirm this is a chroot (/ is the same as PID 1's root, or /proc is unreadable); refusing to delete anything" >&2
    exit 1
fi

# 3. Must look like the LFS build tree.
if [ ! -d /sources ] || [ ! -x /usr/bin/gcc ] || [ ! -x /usr/bin/perl ]; then
    echo "cleanup-ch7: /sources, /usr/bin/gcc or /usr/bin/perl is missing; this is not the finished chapter 7 tree" >&2
    exit 1
fi

mkdir -p /sources/.logs
exec > >(tee -a /sources/.logs/cleanup-ch7.log) 2>&1
echo "== LFS Chapter 7.15: Cleaning =="

echo "-- documentation of the temporary tools"
rm -rf /usr/share/{info,man,doc}/*

echo "-- libtool .la files"
find /usr/{lib,libexec} -name \*.la -delete

echo "-- /tools"
rm -rf /tools

echo "Cleanup Chapter 7 completed."
