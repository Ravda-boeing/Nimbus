#!/bin/bash
# Read-only checks for the LFS Chapter 9 configuration under a mounted root.
set -u

root=${1:-/mnt/lfs}
errors=0

if [ ! -d "$root/etc" ]; then
    echo "usage: $0 [LFS-root]" >&2
    exit 2
fi

ok() { printf 'OK: %s\n' "$1"; }
bad() { printf 'MISSING/WRONG: %s\n' "$1" >&2; errors=$((errors + 1)); }

file_has_line() {
    local rel=$1 line=$2 label=${3:-$1}
    if [ -f "$root/$rel" ] && grep -Fqx -- "$line" "$root/$rel"; then
        ok "$label"
    else
        bad "$label"
    fi
}

link_is() {
    local rel=$1 target=$2 label=${3:-$1}
    if [ -L "$root/$rel" ] && [ "$(readlink "$root/$rel")" = "$target" ]; then
        ok "$label"
    else
        bad "$label should link to $target"
    fi
}

file_has_line etc/hostname Nimbus
file_has_line etc/hosts '127.0.0.1 localhost.localdomain localhost Nimbus'
file_has_line etc/hosts '::1       localhost.localdomain localhost ip6-localhost ip6-loopback'
file_has_line etc/systemd/network/10-ethernet-dhcp.network 'Name=en* eth*'
file_has_line etc/systemd/network/10-ethernet-dhcp.network 'DHCP=ipv4'
file_has_line etc/systemd/network/10-ethernet-dhcp.network 'UseDomains=true'
link_is etc/resolv.conf /run/systemd/resolve/stub-resolv.conf
link_is etc/localtime /usr/share/zoneinfo/Australia/Melbourne
file_has_line etc/vconsole.conf KEYMAP=us
file_has_line etc/vconsole.conf FONT=Lat2-Terminus16
file_has_line etc/locale.conf LANG=en_AU.UTF-8
file_has_line etc/profile '  export LANG=C.UTF-8' 'console locale fallback'
file_has_line etc/inputrc 'set bell-style none'
file_has_line etc/shells /bin/bash

if [ -f "$root/etc/adjtime" ] && [ "$(sed -n '3p' "$root/etc/adjtime")" = UTC ]; then
    ok 'RTC mode is UTC in /etc/adjtime'
else
    bad 'write UTC as the third line of /etc/adjtime'
fi

for rel in \
    etc/systemd/system/multi-user.target.wants/systemd-networkd.service \
    etc/systemd/system/sysinit.target.wants/systemd-resolved.service \
    etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service; do
    if [ -L "$root/$rel" ]; then ok "$rel enabled"; else bad "$rel not enabled"; fi
done

if command -v localedef >/dev/null 2>&1; then
    locales=$(localedef --list-archive --prefix="$root" 2>/dev/null) || locales=
    if printf '%s\n' "$locales" | grep -Eiq '^en_AU\.(utf8|utf-8)$'; then
        ok 'en_AU UTF-8 locale exists in the LFS locale archive'
    else
        bad 'en_AU UTF-8 locale missing from the LFS locale archive'
    fi
else
    bad 'localedef is unavailable on the host; locale archive was not checked'
fi

if [ "$errors" -eq 0 ]; then
    echo 'Chapter 9 checks passed.'
else
    printf 'Chapter 9 check: %s issue(s).\n' "$errors" >&2
    exit 1
fi
