# LFS 13.1, Chapter 8.5.2: Glibc configuration files (recipe format v2)
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/glibc-config.sh
# Install:  npskg install /sources/pkgs/glibc-config-1.npskg   (after glibc)
#
# These are the book's /etc/nsswitch.conf and /etc/ld.so.conf (with the include
# directory), kept apart from the glibc package so a Glibc upgrade cannot replace them.
# /etc/localtime is not here: its target depends on the time zone you choose.
NAME=glibc-config
VERSION=1
SUMMARY='nsswitch.conf and ld.so.conf as given in the LFS book'
DEPENDS=(glibc)

package() {
    install -d -m755 "$PKGDIR/etc/ld.so.conf.d"

    cat > "$PKGDIR/etc/nsswitch.conf" << "EOF2"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF2

    cat > "$PKGDIR/etc/ld.so.conf" << "EOF2"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF2
}
