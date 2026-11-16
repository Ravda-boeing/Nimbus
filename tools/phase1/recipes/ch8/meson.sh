# LFS 13.1-systemd, Chapter 8.59: Meson 1.12.0
NAME=meson
VERSION=1.12.0
TARBALL='meson-1.12.0.tar.gz'
SUMMARY='Build system for software projects'
DEPENDS=(python setuptools)
build() { pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"; }
package() {
    pip3 install --root="$PKGDIR" --no-index --find-links dist meson || return 1
    install -vDm644 data/shell-completions/bash/meson "$PKGDIR/usr/share/bash-completion/completions/meson" || return 1
    install -vDm644 data/shell-completions/zsh/_meson "$PKGDIR/usr/share/zsh/site-functions/_meson"
}
