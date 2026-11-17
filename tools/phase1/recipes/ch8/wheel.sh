# LFS 13.1-systemd, Chapter 8.57: Wheel 0.48.0
NAME=wheel
VERSION=0.48.0
TARBALL='wheel-0.48.0.tar.gz'
SUMMARY='Python wheel packaging implementation'
DEPENDS=(python flit-core packaging)
build() { pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"; }
package() { pip3 install --root="$PKGDIR" --no-index --find-links dist wheel; }
