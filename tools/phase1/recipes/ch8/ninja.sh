# LFS 13.1-systemd, Chapter 8.20: Ninja 1.13.2
# The book notes its CMake-based tests cannot run in the chroot; --bootstrap
# rebuilds Ninja for this system and is the package's basic functional check.

NAME=ninja
VERSION=1.13.2
TARBALL='ninja-1.13.2.tar.gz'
SUMMARY='Small build system with a focus on speed'
LICENSE='Apache-2.0'
SOURCE_MD5=76c00637fde44909cd7d56f8d73f2042

build() {
    local src_archive
    src_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$src_archive" | md5sum -c - || return 1

    python3 configure.py --bootstrap --verbose
}

package() {
    install -vDm755 ninja "$PKGDIR/usr/bin/ninja" || return 1
    install -vDm644 misc/bash-completion \
        "$PKGDIR/usr/share/bash-completion/completions/ninja" || return 1
    install -vDm644 misc/zsh-completion \
        "$PKGDIR/usr/share/zsh/site-functions/_ninja"
}
