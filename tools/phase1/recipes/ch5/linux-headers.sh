# LFS chapter 5.4: Linux API Headers. Less than 0.1 SBU.
# The kernel's sanitized headers, for Glibc to build against.
#
# Checked against the 13.1 book page (5.4). The book is the authority.
TARBALL='linux-[0-9]*.tar.*'

build() {
    # make sure there are no stale files in the tree
    make mrproper

    # headers_install is not used: it needs rsync
    make headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include "$LFS/usr"
}
