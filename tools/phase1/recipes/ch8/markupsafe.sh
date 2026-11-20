# LFS 13.1-systemd r13.1-42, Chapter 8.75: MarkupSafe 3.0.4
NAME=markupsafe
VERSION=3.0.4
TARBALL='markupsafe-3.0.4.tar.gz'
SUMMARY='Safe string handling for Python markup'
DEPENDS=(python)
build() { pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"; }
package() { pip3 install --root="$PKGDIR" --no-index --find-links dist Markupsafe; }
