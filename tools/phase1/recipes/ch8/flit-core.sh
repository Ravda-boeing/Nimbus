# LFS 13.1-systemd, Chapter 8.55: Flit-Core 4.0.2
NAME=flit-core
VERSION=4.0.2
TARBALL='flit_core-4.0.2.tar.gz'
SUMMARY='Python Flit build backend'
DEPENDS=(python)
build() { pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"; }
package() { pip3 install --root="$PKGDIR" --no-index --find-links dist flit_core; }
