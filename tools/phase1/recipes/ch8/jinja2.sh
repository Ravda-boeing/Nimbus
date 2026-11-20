# LFS 13.1-systemd r13.1-42, Chapter 8.76: Jinja2 3.1.6
NAME=jinja2
VERSION=3.1.6
TARBALL='jinja2-3.1.6.tar.gz'
SUMMARY='Python template engine'
DEPENDS=(python markupsafe)
build() { pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"; }
package() { pip3 install --root="$PKGDIR" --no-index --find-links dist --no-deps Jinja2; }
