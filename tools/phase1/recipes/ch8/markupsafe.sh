# LFS 13.1-systemd, Chapter 8.75: MarkupSafe 3.0.3
NAME=markupsafe
VERSION=3.0.3
TARBALL='MarkupSafe-3.0.3.tar.gz'
SUMMARY='Safe string handling for Python markup'
DEPENDS=(python)
build() { pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"; }
package() { pip3 install --root="$PKGDIR" --no-index --find-links dist Markupsafe; }
