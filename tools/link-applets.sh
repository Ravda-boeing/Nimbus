#!/bin/sh
# Usage: link-applets.sh <root-dir>
# Creates a symlink to /bin/busybox for every applet that doesn't already
# exist in <root-dir>. Real Nimbus scripts (login, power, init...) win.
set -eu

root="${1:?usage: link-applets.sh <root-dir>}"
bb="$root/bin/busybox"

[ -x "$bb" ] || { echo "link-applets: $bb missing or not executable" >&2; exit 1; }

cd "$root"
"$bb" --list-full | while read -r p; do
    if [ -e "$p" ] || [ -L "$p" ]; then
        continue
    fi
    mkdir -p "$(dirname "$p")"
    ln -s /bin/busybox "$p"
done
