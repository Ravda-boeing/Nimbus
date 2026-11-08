#!/usr/bin/bash
# LFS 13.1-systemd, Chapter 7.11: Perl-5.44.0
# Run as root inside the LFS chroot.
#
# Reconstructed on 2026-11-08, after the fact: Perl was first built by hand with
# `sh Configure -des` and `-D useshrplib`. The installed perl reports prefix=/usr,
# privlib=archlib=/usr/lib/perl5/5.44/core_perl, sitelib=/usr/lib/perl5/5.44/site_perl
# useshrplib=true, vendorprefix=/usr, sitearch=/usr/lib/perl5/5.44/site_perl and
# vendorlib=vendorarch=/usr/lib/perl5/5.44/vendor_perl; this recipe is written to
# reproduce those settings. It has not been compared with the book's page.
set -euo pipefail

if [ "$(id -u)" -ne 0 ] ||
   [ ! -f /sources/perl-5.44.0.tar.xz ] ||
   [ ! -x /usr/bin/gcc ]; then
    echo "perl-ch7: expected root inside the LFS chroot" >&2
    exit 1
fi

mkdir -p /sources/.work /sources/.logs
work=/sources/.work/perl-ch7
rm -rf "$work"
mkdir -p "$work"

exec > >(tee -a /sources/.logs/perl-ch7.log) 2>&1
echo "== LFS Chapter 7.11: Perl-5.44.0 =="

tar -xf /sources/perl-5.44.0.tar.xz -C "$work" --strip-components=1
cd "$work"

sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.44/core_perl     \
             -D archlib=/usr/lib/perl5/5.44/core_perl     \
             -D sitelib=/usr/lib/perl5/5.44/site_perl     \
             -D sitearch=/usr/lib/perl5/5.44/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.44/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.44/vendor_perl
make
make install

echo "Perl Chapter 7 build and installation completed."
