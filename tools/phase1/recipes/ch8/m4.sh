# LFS 13.1, Chapter 8.14: M4 1.4.21
# Built using the final 13.1-systemd release instructions.
# Recipe format v2, built with npskg.

_tb=$(tarball_path 'm4-[0-9]*.tar.xz')
_v=${_tb##*/m4-}

NAME=m4
VERSION=${_v%.tar.xz}
TARBALL='m4-[0-9]*.tar.xz'
SUMMARY='Macro processor'
LICENSE='GPL-3.0-or-later'

build() {
    # Nimbus patch: gnulib's configure selects the recursive
    # spawn_faction_addchdir.c wrapper when glibc only has the _np function.
    # Treat a working _np function as "available". Fails loudly if the
    # upstream text is not found exactly once.
    perl -0pi -e '
        $c += s{(  if test \$ac_cv_func_posix_spawn_file_actions_addchdir = yes; then\n\s+REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=1\n)(  else\n    HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=0\n  fi\n)}{$1  elif test \$ac_cv_func_posix_spawn_file_actions_addchdir_np = yes; then\n    HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=1\n$2}g;
        END { die "m4 recipe: configure patch matched $c times, expected 1\n" unless $c == 1 }
    ' configure || return 1
    [ "$(grep -cF 'elif test $ac_cv_func_posix_spawn_file_actions_addchdir_np = yes; then' configure)" = 1 ] || {
        echo "ERROR: configure patch not present exactly once"; return 1; }

    gl_cv_onwards_func_posix_spawn_file_actions_addchdir_np=yes \
        ./configure --prefix=/usr || return 1

    # Refuse to build if gnulib's recursive compatibility wrapper is selected.
    local lib_plan
    lib_plan=$(make -C lib -n libm4.a) || return 1
    case "$lib_plan" in
        *spawn_faction_addchdir*)
            echo "ERROR: recursive spawn_faction_addchdir wrapper would be compiled"
            return 1
            ;;
    esac

    make || return 1

    # Belt and braces: the wrapper must not be in the built archive.
    if ar t lib/libm4.a | grep -q spawn_faction_addchdir; then
        echo "ERROR: spawn_faction_addchdir object found in libm4.a"
        return 1
    fi

    timeout 7200 make check
}

package() {
    make DESTDIR="$PKGDIR" install
    rm -f "$PKGDIR/usr/share/info/dir"
}
