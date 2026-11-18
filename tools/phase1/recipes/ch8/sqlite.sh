# LFS 13.1-systemd, Chapter 8.52: Sqlite 3.54.1
NAME=sqlite
VERSION=3.54.1
TARBALL='sqlite-autoconf-3540100.tar.gz'
SUMMARY='Embedded SQL database engine'
build() {
    ./configure --prefix=/usr --disable-static --enable-fts4 --enable-fts5 \
      CPPFLAGS='-D SQLITE_ENABLE_COLUMN_METADATA=1 -D SQLITE_ENABLE_UNLOCK_NOTIFY=1 -D SQLITE_ENABLE_DBSTAT_VTAB=1 -D SQLITE_SECURE_DELETE=1' || return 1
    make 'LDFLAGS.rpath=' || return 1
}
package() { make DESTDIR="$PKGDIR" install || return 1; }
