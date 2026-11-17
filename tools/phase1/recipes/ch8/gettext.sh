# LFS 13.1-systemd, Chapter 8.36: Gettext 1.0
# Recipe format v2, built and staged with npskg.

NAME=gettext
VERSION=1.0
TARBALL='gettext-1.0.tar.xz'
SUMMARY='Utilities for internationalization and localization'

build() {
    # Nimbus patch: gnulib selects its recursive compatibility wrapper for
    # posix_spawn_file_actions_addchdir when glibc only provides the _np form.
    # Glibc's _np function is available here; mark the operation as available
    # so gnulib does not compile the wrapper that caused tests to hang.
    perl -0pi -e '
        $c += s{(  if test \$ac_cv_func_posix_spawn_file_actions_addchdir = yes; then\n\s+REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=1\n)\s+else\n\s+HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=0\n\s+fi}{$1  elif test \$ac_cv_func_posix_spawn_file_actions_addchdir_np = yes; then\n    HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=1\n  else\n    HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=0\n  fi}g;
        END { die "gettext recipe: configure patch matched $c times, expected 1\n" unless $c == 1 }
    ' gettext-tools/configure || return 1

    [ "$(grep -cF 'elif test $ac_cv_func_posix_spawn_file_actions_addchdir_np = yes; then' gettext-tools/configure)" = 1 ] || {
        echo "ERROR: configure patch not present exactly once"; return 1; }

    ./configure --prefix=/usr \
                --disable-static \
                --docdir=/usr/share/doc/gettext-$VERSION || return 1
    make || return 1
    timeout 7200 make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    chmod -v 0755 "$PKGDIR/usr/lib/preloadable_libintl.so" || return 1
    # Do not package the shared Info index; Glibc owns it in the LFS root.
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
