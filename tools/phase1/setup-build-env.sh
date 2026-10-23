#!/bin/bash
# Nimbus Phase 1, step 2: LFS chapter 4 (final preparations).
#   - directory layout under $LFS
#   - the unprivileged "lfs" build user, with a clean environment
#   - $LFS/sources for the source tarballs
# Safe to run more than once. Needs the build disk mounted at $LFS.
#
#   tools/phase1/setup-build-env.sh
#
# Afterwards, become the build user with:   sudo su - lfs
# Undo the one host change this makes (at the start of LFS chapter 7):
#   sudo mv /etc/bash.bashrc.NOUSE /etc/bash.bashrc
set -euo pipefail

LFS="${LFS:-/mnt/lfs}"

# re-run through sudo if needed
[ "$(id -u)" -eq 0 ] || exec sudo LFS="$LFS" NIMBUS_ALLOW_UNMOUNTED="${NIMBUS_ALLOW_UNMOUNTED:-}" "$0" "$@"

if [ -z "${NIMBUS_ALLOW_UNMOUNTED:-}" ] && ! mountpoint -q "$LFS"; then
    echo "setup-build-env: $LFS is not a mount point. Run tools/phase1/lfs-disk.sh mount first." >&2
    exit 1
fi

echo "== Directory layout in $LFS =="
mkdir -pv "$LFS"/{etc,var} "$LFS"/usr/{bin,lib,sbin}
for i in bin lib sbin; do
    [ -e "$LFS/$i" ] || ln -sv "usr/$i" "$LFS/$i"
done
case $(uname -m) in x86_64) mkdir -pv "$LFS/lib64" ;; esac
mkdir -pv "$LFS/tools"
mkdir -pv "$LFS/sources"
chmod -v a+wt "$LFS/sources"

echo; echo "== Build user 'lfs' =="
getent group lfs >/dev/null || groupadd lfs
id lfs >/dev/null 2>&1 || useradd -s /bin/bash -g lfs -m -k /dev/null lfs
chown -v lfs "$LFS"/{usr{,/*},var,etc,tools}
case $(uname -m) in x86_64) chown -v lfs "$LFS/lib64" ;; esac

echo; echo "== Clean environment for lfs =="
home=$(getent passwd lfs | cut -d: -f6)
cat > "$home/.bash_profile" <<'PROFILE'
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
PROFILE
cat > "$home/.bashrc" <<BASHRC
set +h
umask 022
LFS=$LFS
LC_ALL=POSIX
LFS_TGT=\$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:\$PATH; fi
PATH=\$LFS/tools/bin:\$PATH
CONFIG_SITE=\$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j\$(nproc)
BASHRC
chown lfs:lfs "$home/.bash_profile" "$home/.bashrc"
echo "wrote $home/.bash_profile and $home/.bashrc"

if [ -e /etc/bash.bashrc ] && [ ! -e /etc/bash.bashrc.NOUSE ]; then
    mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
    echo "(restore later: sudo mv /etc/bash.bashrc.NOUSE /etc/bash.bashrc)"
fi

echo; echo "Done. Next:  sudo su - lfs"
