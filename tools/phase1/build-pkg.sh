#!/bin/bash
# Nimbus Phase 1: build ONE package from a recipe. Run as the lfs user.
#
#   build-pkg.sh <recipe.sh>
#
# A recipe is a small shell file that sets
#   TARBALL='binutils-*.tar.*'     glob matching exactly one file in $LFS/sources
# and defines
#   build()                        commands, run inside the unpacked source dir
#
# Recipes may call  tarball_path '<glob>'  to find another file in $LFS/sources.
#
# For each package this script: checks the environment, unpacks the tarball
# into $LFS/sources/.work/<name>, runs build(), logs everything to
# $LFS/sources/.logs/<name>.log, records the time in $LFS/sources/.logs/times.txt,
# and deletes the work dir on success (KEEP=1 keeps it; failures always keep it).
set -euo pipefail

die() { echo "build-pkg: $*" >&2; exit 1; }

recipe="${1:-}"
[ -n "$recipe" ] && [ -f "$recipe" ] || die "usage: $0 <recipe.sh>"
name=$(basename "$recipe" .sh)

# the book's golden rule: never build the temporary toolchain as root
if [ "$(id -un)" != lfs ] && [ -z "${NIMBUS_ALLOW_ANYUSER:-}" ]; then
    die "run this as the lfs user (sudo su - lfs), not $(id -un)"
fi
: "${LFS:?LFS is not set (is this a login shell of the lfs user?)}"
: "${LFS_TGT:?LFS_TGT is not set (is this a login shell of the lfs user?)}"
[ -d "$LFS/sources" ] || die "$LFS/sources not found (is the build disk mounted?)"

logs="$LFS/sources/.logs"
work="$LFS/sources/.work/$name"
mkdir -p "$logs" "$LFS/sources/.work"

shopt -s nullglob

# helper for recipes: print the one file in $LFS/sources matching a glob
tarball_path() {
    local m=( "$LFS"/sources/$1 )
    if [ "${#m[@]}" -ne 1 ]; then
        echo "build-pkg: expected exactly one file matching $1 in $LFS/sources, found ${#m[@]}" >&2
        return 1
    fi
    printf '%s\n' "${m[0]}"
}

unset TARBALL
# shellcheck disable=SC1090
source "$recipe"
[ -n "${TARBALL:-}" ] || die "$recipe does not set TARBALL"
declare -F build >/dev/null || die "$recipe does not define build()"

tarball=$(tarball_path "$TARBALL") || exit 1

rm -rf "$work"
mkdir -p "$work"
tar -xf "$tarball" -C "$work" --strip-components=1
cd "$work"

echo "== $name: building from $(basename "$tarball") ==" | tee "$logs/$name.log"
start=$SECONDS
set +e
( set -e; build ) 2>&1 | tee -a "$logs/$name.log"
rc=${PIPESTATUS[0]}
set -e
elapsed=$((SECONDS - start))

if [ "$rc" -ne 0 ]; then
    echo "build-pkg: $name FAILED after ${elapsed}s (exit $rc)" >&2
    echo "  work dir kept: $work" >&2
    echo "  log:           $logs/$name.log" >&2
    exit "$rc"
fi

printf '%-28s %6ss\n' "$name" "$elapsed" | tee -a "$logs/times.txt"
if [ -z "${KEEP:-}" ]; then cd / && rm -rf "$work"; fi
echo "OK: $name (${elapsed}s)"
