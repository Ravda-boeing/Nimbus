#!/bin/bash
# Nimbus Phase 1: check that the host can build an LFS-style system.
# Modelled on the version-check in the LFS book (chapter 2). The book's own
# script is the authority; this one also checks a few extras we need.
# Usage: tools/phase1/check-host.sh

errors=0
ok()   { printf 'OK:    %s\n' "$1"; }
warn() { printf 'WARN:  %s\n' "$1"; }
err()  { printf 'ERROR: %s\n' "$1"; errors=$((errors+1)); }

# ver_check <name> <command> <minimum version>
ver_check() {
    local name=$1 cmd=$2 min=$3 v
    if ! command -v "$cmd" >/dev/null 2>&1; then err "$name: '$cmd' not found"; return; fi
    v=$("$cmd" --version 2>&1 | grep -v '^$' | head -n1 | grep -Eo '[0-9]+(\.[0-9]+)+' | head -n1)
    if [ -z "$v" ]; then err "$name: could not read version"; return; fi
    if [ "$(printf '%s\n%s\n' "$min" "$v" | sort -V | head -n1)" = "$min" ]; then
        ok "$name $v (>= $min)"
    else
        err "$name $v is too old ($min or later required)"
    fi
}

# need <name> <command>
need() { command -v "$2" >/dev/null 2>&1 && ok "$1 present" || err "$1 missing ('$2' not found)"; }

echo "== Required tool versions =="
ver_check Bash     bash    3.2
ver_check Binutils ld      2.38
ver_check Bison    bison   2.7
ver_check GCC      gcc     12.2
ver_check 'GCC C++' g++    12.2
ver_check Make     make    4.0
ver_check Gawk     gawk    4.0
ver_check Perl     perl    5.8
ver_check Python   python3 3.4
ver_check M4       m4      1.4
ver_check Patch    patch   2.5
ver_check Sed      sed     4.1
ver_check Tar      tar     1.22
ver_check Texinfo  makeinfo 5.0
ver_check Xz       xz      5.0

echo; echo "== Other tools =="
need Bzip2 bzip2; need Gzip gzip; need Grep grep; need Diffutils diff
need Findutils find; need Wget wget; need Bc bc; need Mke2fs mke2fs

echo; echo "== Symlinks LFS requires =="
sh_target=$(readlink -f /bin/sh)
[ "$(basename "$sh_target")" = bash ] && ok "/bin/sh -> $sh_target" \
    || err "/bin/sh -> $sh_target (must be bash; fix: sudo dpkg-reconfigure dash, answer No)"
awk_target=$(readlink -f "$(command -v awk)")
[ "$(basename "$awk_target")" = gawk ] && ok "awk -> $awk_target" \
    || err "awk -> $awk_target (must be gawk; fix: sudo apt install gawk)"
if command -v yacc >/dev/null 2>&1 && yacc --version 2>&1 | grep -qi bison; then ok "yacc is bison"
else err "yacc is not bison (fix: sudo apt install bison)"; fi

echo; echo "== Compiler works =="
tmp=$(mktemp -d)
printf 'int main(){return 0;}\n' > "$tmp/t.c"
printf '#include <iostream>\nint main(){std::cout<<"";return 0;}\n' > "$tmp/t.cc"
gcc -o "$tmp/c" "$tmp/t.c" 2>/dev/null && "$tmp/c" && ok "gcc compiles and runs" || err "gcc cannot build a C program"
g++ -o "$tmp/cc" "$tmp/t.cc" 2>/dev/null && "$tmp/cc" && ok "g++ compiles and runs" || err "g++ cannot build a C++ program"
rm -rf "$tmp"

echo; echo "== Kernel and resources =="
kver=$(uname -r | cut -d- -f1)
[ "$(printf '5.4\n%s\n' "$kver" | sort -V | head -n1)" = 5.4 ] && ok "host kernel $kver (>= 5.4)" || err "host kernel $kver is too old"
[ -e /dev/ptmx ] && ok "UNIX 98 PTY support (/dev/ptmx)" || err "no /dev/ptmx"
cores=$(nproc); mem_gb=$(awk '/MemTotal/ {printf "%d", $2/1048576}' /proc/meminfo)
[ "$cores" -ge 4 ] && ok "$cores CPU cores" || warn "$cores CPU cores (4 recommended; builds will be slow)"
[ "$mem_gb" -ge 7 ] && ok "~${mem_gb} GB RAM" || warn "~${mem_gb} GB RAM (8 recommended)"
free_gb=$(df -BG --output=avail "$HOME" | tail -n1 | tr -dc 0-9)
[ "$free_gb" -ge 20 ] && ok "${free_gb} GB free under \$HOME" || warn "only ${free_gb} GB free under \$HOME (need ~16 GB for the build disk plus headroom)"

echo
if [ "$errors" -eq 0 ]; then echo "Host looks ready."; else echo "$errors problem(s) to fix before starting."; exit 1; fi
