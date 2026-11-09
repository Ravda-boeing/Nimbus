#!/bin/bash
# Self-test for npskg. Needs no root: everything happens in a temporary directory.
#   tools/npskg/test.sh
set -u
export LC_ALL=C
HERE=$(cd "$(dirname "$0")" && pwd)
NP="$HERE/npskg"
W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
pass=0; failn=0

ok()   { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad()  { failn=$((failn+1)); printf 'FAIL  %s\n' "$1"; }
check(){ local d=$1; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }
refuse(){ local d=$1; shift; if "$@" >"$W/out" 2>&1; then bad "$d (should have been refused)"; else ok "$d"; fi; }
said()  { grep -q -- "$1" "$W/out" && ok "$2" || { bad "$2 (output was: $(head -c 200 "$W/out"))"; }; }

# stage <dir> <name> ... builds a small tree
mkpkg() {  # name version "Depends" "Replaces" "Conflicts" "Provides" ; stage in $W/stage-<name>
    local n=$1 v=$2 s="$W/stage-$1"
    rm -rf "$s"; mkdir -p "$s/usr/bin" "$s/usr/share/doc/$n" "$s/var/lib/$n"
    printf '#!/bin/sh\necho %s\n' "$n" > "$s/usr/bin/$n"; chmod 755 "$s/usr/bin/$n"
    echo "$n readme" > "$s/usr/share/doc/$n/README"
    ln -s "$n" "$s/usr/bin/$n-link"
    { echo "Name: $n"; echo "Version: $v"; echo "Architecture: x86_64"; echo "Summary: test package $n"
      [ -z "${3:-}" ] || echo "Depends: $3"; [ -z "${4:-}" ] || echo "Replaces: $4"
      [ -z "${5:-}" ] || echo "Conflicts: $5"; [ -z "${6:-}" ] || echo "Provides: $6"; } > "$W/META-$n"
    "$NP" --out "$W/pkgs" pack "$W/META-$n" "$s" >/dev/null
}
R() { echo "$W/root-$1"; }
newroot() { rm -rf "$W/root-$1"; mkdir -p "$W/root-$1"; }

echo "== basics"
mkpkg hello 1.0
newroot a; RA=$(R a)
check "install a package into --root" "$NP" --root "$RA" install "$W/pkgs/hello-1.0.npskg"
check "installed file exists and runs" test -x "$RA/usr/bin/hello"
check "symlink was installed" test -L "$RA/usr/bin/hello-link"
"$NP" --root "$RA" list > "$W/out"; said "hello 1.0" "list shows hello 1.0"
"$NP" --root "$RA" files hello > "$W/out"; said "/usr/bin/hello" "files lists /usr/bin/hello"
"$NP" --root "$RA" owns /usr/bin/hello > "$W/out"; said "hello" "owns finds the owner"
refuse "owns exits non-zero for an unowned path" "$NP" --root "$RA" owns /etc/nothing
check "verify passes on a fresh install" "$NP" --root "$RA" verify hello
"$NP" --root "$RA" info hello > "$W/out"; said "Version: 1.0" "info prints META"
refuse "installing the same package again is refused" "$NP" --root "$RA" install "$W/pkgs/hello-1.0.npskg"
said "already installed" "  ...with a clear message"

echo "== dependencies"
mkpkg greeter 2.0 "hello (>= 1.0)"
newroot b; RB=$(R b)
refuse "missing dependency is refused" "$NP" --root "$RB" install "$W/pkgs/greeter-2.0.npskg"
said "unmet dependencies" "  ...with a clear message"
check "dependency satisfied -> install works" "$NP" --root "$RA" install "$W/pkgs/greeter-2.0.npskg"
mkpkg needsnew 1.0 "hello (>= 9.0)"
refuse "version constraint not met is refused" "$NP" --root "$RA" install "$W/pkgs/needsnew-1.0.npskg"
mkpkg needsexact 1.0 "hello (= 1.0)"
check "exact version constraint met" "$NP" --root "$RA" install "$W/pkgs/needsexact-1.0.npskg"
refuse "removing a package that others depend on is refused" "$NP" --root "$RA" remove hello
said "required by" "  ...naming the dependents"
mkpkg provider 1.0 "" "" "" "virtual-thing"
mkpkg wantsvirtual 1.0 "virtual-thing"
newroot c; RC=$(R c)
"$NP" --root "$RC" install "$W/pkgs/provider-1.0.npskg" >/dev/null 2>&1
check "Provides satisfies a dependency" "$NP" --root "$RC" install "$W/pkgs/wantsvirtual-1.0.npskg"
mkpkg hater 1.0 "" "" "hello"
refuse "Conflicts with an installed package is refused" "$NP" --root "$RA" install "$W/pkgs/hater-1.0.npskg"

echo "== file conflicts and Replaces"
mkdir -p "$W/stage-thief/usr/bin"; printf '#!/bin/sh\necho stolen\n' > "$W/stage-thief/usr/bin/hello"; chmod 755 "$W/stage-thief/usr/bin/hello"
printf 'Name: thief\nVersion: 1.0\nArchitecture: x86_64\n' > "$W/META-thief"; "$NP" --out "$W/pkgs" pack "$W/META-thief" "$W/stage-thief" >/dev/null
refuse "file owned by another package is a conflict" "$NP" --root "$RA" install "$W/pkgs/thief-1.0.npskg"
said "owned by hello" "  ...naming the owner"
printf 'Name: thief2\nVersion: 1.0\nArchitecture: x86_64\nReplaces: hello\n' > "$W/META-thief2"; "$NP" --out "$W/pkgs" pack "$W/META-thief2" "$W/stage-thief" >/dev/null
newroot d; RD=$(R d); "$NP" --root "$RD" install "$W/pkgs/hello-1.0.npskg" >/dev/null 2>&1
check "Replaces allows taking over a file" "$NP" --root "$RD" install "$W/pkgs/thief2-1.0.npskg"
"$NP" --root "$RD" owns /usr/bin/hello > "$W/out"; said "thief2" "ownership moved to the new package"
"$NP" --root "$RD" remove hello >/dev/null 2>&1
check "removing the old package keeps the file it lost" test -x "$RD/usr/bin/hello"
check "...and the new owner still verifies" "$NP" --root "$RD" verify thief2

echo "== remove"
newroot e; RE=$(R e)
mkpkg one 1.0; mkpkg two 1.0
"$NP" --root "$RE" install "$W/pkgs/one-1.0.npskg" >/dev/null 2>&1; "$NP" --root "$RE" install "$W/pkgs/two-1.0.npskg" >/dev/null 2>&1
check "remove works" "$NP" --root "$RE" remove one
check "its files are gone" test ! -e "$RE/usr/bin/one"
check "its own directories are pruned" test ! -d "$RE/usr/share/doc/one"
check "directories shared with another package stay" test -d "$RE/usr/bin"
check "the other package is untouched" "$NP" --root "$RE" verify two
check "the record is gone" test ! -d "$RE/var/lib/npskg/installed/one"
refuse "removing something not installed fails" "$NP" --root "$RE" remove one
check "--force removes despite dependents" "$NP" --root "$RA" --force remove hello

echo "== existing files nobody owns"
newroot f; RF=$(R f); mkdir -p "$RF/usr/bin"; echo old > "$RF/usr/bin/hello"
refuse "unowned existing file is refused" "$NP" --root "$RF" install "$W/pkgs/hello-1.0.npskg"
said "owned by no package" "  ...with a clear message"
check "--force overwrites it" "$NP" --root "$RF" --force install "$W/pkgs/hello-1.0.npskg"
check "...and it now verifies" "$NP" --root "$RF" verify hello

echo "== verify"
newroot g; RG=$(R g); "$NP" --root "$RG" install "$W/pkgs/hello-1.0.npskg" >/dev/null 2>&1
echo tampered >> "$RG/usr/bin/hello"
refuse "verify detects a modified file" "$NP" --root "$RG" verify hello; said "MODIFIED" "  ...reports MODIFIED"
printf '#!/bin/sh\necho hello\n' > "$RG/usr/bin/hello"; chmod 755 "$RG/usr/bin/hello"
rm "$RG/usr/share/doc/hello/README"
refuse "verify detects a missing file" "$NP" --root "$RG" verify hello; said "MISSING" "  ...reports MISSING"
echo "hello readme" > "$RG/usr/share/doc/hello/README"
chmod 700 "$RG/usr/bin/hello"
refuse "verify detects a changed mode" "$NP" --root "$RG" verify hello; said "MODE" "  ...reports MODE"
chmod 755 "$RG/usr/bin/hello"; rm "$RG/usr/bin/hello-link"; ln -s elsewhere "$RG/usr/bin/hello-link"
refuse "verify detects a changed symlink" "$NP" --root "$RG" verify hello; said "CHANGED" "  ...reports CHANGED"

echo "== hostile or broken packages"
mkdir -p "$W/x"; rm -rf "$W/x"/*; tar -xpf "$W/pkgs/hello-1.0.npskg" -C "$W/x"
cp "$W/x/FILES" "$W/FILES.orig"
# a) path traversal in the record
printf 'f\t644\tdeadbeef\t/../escape\n' >> "$W/x/FILES"
tar -C "$W/x" -cJf "$W/pkgs/evil1.npskg" META FILES SCRIPTS data
newroot h; RH=$(R h); refuse "path traversal in FILES is refused" "$NP" --root "$RH" install "$W/pkgs/evil1.npskg"
# b) an unlisted extra file inside data/
cp "$W/FILES.orig" "$W/x/FILES"; echo evil > "$W/x/data/usr/bin/extra"
tar -C "$W/x" -cJf "$W/pkgs/evil2.npskg" META FILES SCRIPTS data
refuse "files in the archive that FILES does not list are refused" "$NP" --root "$RH" install "$W/pkgs/evil2.npskg"; said "tampered\|do not match" "  ...detected as a mismatch"
rm "$W/x/data/usr/bin/extra"
# c) altered file content (hash mismatch)
echo changed > "$W/x/data/usr/share/doc/hello/README"
tar -C "$W/x" -cJf "$W/pkgs/evil3.npskg" META FILES SCRIPTS data
refuse "altered file content is refused" "$NP" --root "$RH" install "$W/pkgs/evil3.npskg"
check "nothing was installed by any of them" test ! -e "$RH/usr/bin/hello"
# d) not a package at all
echo junk > "$W/junk.npskg"; refuse "a non-package file is refused" "$NP" --root "$RH" install "$W/junk.npskg"
# e) absolute symlink in the target tree leading outside the root
newroot i; RI=$(R i); mkdir -p "$RI/var" "$W/outside"; ln -s "$W/outside" "$RI/var/run"
mkdir -p "$W/stage-esc/var/run"; echo x > "$W/stage-esc/var/run/pwned"
printf 'Name: esc\nVersion: 1.0\nArchitecture: x86_64\n' > "$W/META-esc"; "$NP" --out "$W/pkgs" pack "$W/META-esc" "$W/stage-esc" >/dev/null
refuse "install through a symlink that leaves the root is refused" "$NP" --root "$RI" install "$W/pkgs/esc-1.0.npskg"; said "outside the root" "  ...with a clear message"
check "...and nothing was written outside" test -z "$(ls -A "$W/outside")"
# f) same check on remove: a record that points through an escaping symlink
mkdir -p "$W/outside"; echo precious > "$W/outside/pwned"
newroot j; RJ=$(R j); mkdir -p "$RJ/var/lib/npskg/installed/esc"
cp "$W/META-esc" "$RJ/var/lib/npskg/installed/esc/META"; printf 'd\t755\t-\t/var\nd\t755\t-\t/var/run\nf\t644\tx\t/var/run/pwned\n' > "$RJ/var/lib/npskg/installed/esc/FILES"
ln -s "$W/outside" "$RJ/var/run"
refuse "remove through an escaping symlink is refused" "$NP" --root "$RJ" remove esc
check "...and the file outside is still there" test -f "$W/outside/pwned"

echo "== scripts"
mkdir -p "$W/sc"; printf '#!/bin/sh\nexit 1\n' > "$W/sc/preinst"
"$NP" --out "$W/pkgs" pack "$W/META-hello" "$W/stage-hello" "$W/sc" >/dev/null 2>&1
newroot k; RK=$(R k)
refuse "a failing preinst aborts the install" "$NP" --root "$RK" install "$W/pkgs/hello-1.0.npskg"
check "...and nothing was installed" test ! -e "$RK/usr/bin/hello"
rm "$W/sc/preinst"; printf '#!/bin/sh\necho "root is $NPSKG_ROOT" > "$NPSKG_ROOT/post.txt"\nexit 3\n' > "$W/sc/postinst"
"$NP" --out "$W/pkgs" pack "$W/META-hello" "$W/stage-hello" "$W/sc" >/dev/null 2>&1
refuse "a failing postinst makes the command fail" "$NP" --root "$RK" install "$W/pkgs/hello-1.0.npskg"
check "...but the package is recorded as installed" "$NP" --root "$RK" verify hello
check "postinst received NPSKG_ROOT" grep -q "root is" "$RK/post.txt"

echo "== things in the way"
mkpkg hello 1.0
newroot l; RL=$(R l); mkdir -p "$RL/usr"; echo "i am a file, not a directory" > "$RL/usr/share"
refuse "a file where the package needs a directory is refused" "$NP" --root "$RL" install "$W/pkgs/hello-1.0.npskg"
said "in the way" "  ...with a clear message"
refuse "--force does not replace it either" "$NP" --root "$RL" --force install "$W/pkgs/hello-1.0.npskg"
check "the file was left alone" grep -q "i am a file" "$RL/usr/share"
check "nothing else was installed" test ! -e "$RL/usr/bin/hello"
newroot l2; RL2=$(R l2); mkdir -p "$RL2/usr/bin/hello"
refuse "a directory where the package has a file is refused" "$NP" --root "$RL2" --force install "$W/pkgs/hello-1.0.npskg"
check "the directory was left alone" test -d "$RL2/usr/bin/hello"

echo "== rollback"
mkdir -p "$W/bin"; cat > "$W/bin/tar" <<'FAKE'
#!/bin/sh
# test double: do the real extraction, then report failure (as if the disk filled up half way)
for a in "$@"; do
    if [ "$a" = "--keep-directory-symlink" ] && [ -n "$NPSKG_FAKE_TAR_FAIL" ]; then /usr/bin/env tar "$@"; exit 1; fi
done
exec /usr/bin/env tar "$@"
FAKE
chmod +x "$W/bin/tar"
newroot r; RR=$(R r); mkdir -p "$RR/usr/share"; echo keep > "$RR/usr/share/keepme"
REALTAR=$(command -v tar); sed -i "s#/usr/bin/env tar#$REALTAR#g" "$W/bin/tar"
if PATH="$W/bin:$PATH" NPSKG_FAKE_TAR_FAIL=1 "$NP" --root "$RR" install "$W/pkgs/hello-1.0.npskg" > "$W/out" 2>&1; then bad "a failed extraction must fail the install"; else ok "a failed extraction fails the install"; fi
said "new files were removed" "  ...and says it undid the install"
check "new files were rolled back" test ! -e "$RR/usr/bin/hello"
check "new directories were rolled back" test ! -d "$RR/var/lib/hello"
check "no package record was left" test ! -d "$RR/var/lib/npskg/installed/hello"
check "pre-existing files were left alone" grep -q keep "$RR/usr/share/keepme"
check "pre-existing directories were left alone" test -d "$RR/usr/share"
check "the same install works afterwards" "$NP" --root "$RR" install "$W/pkgs/hello-1.0.npskg"

echo "== locking"
newroot m; RM=$(R m); mkdir -p "$RM/var/lib/npskg/lock"
refuse "a held lock refuses a second run" "$NP" --root "$RM" install "$W/pkgs/hello-1.0.npskg"; said "another npskg" "  ...with a clear message"

echo "== build from a recipe"
mkdir -p "$W/src/tool-3.1" "$W/sources"
printf '#!/bin/sh\necho built\n' > "$W/src/tool-3.1/tool.sh"
printf 'all:\n\t@echo compiled\ninstall:\n\tmkdir -p $(DESTDIR)/usr/bin\n\tinstall -m 755 tool.sh $(DESTDIR)/usr/bin/tool\n' > "$W/src/tool-3.1/Makefile"
tar -C "$W/src" -czf "$W/sources/tool-3.1.tar.gz" tool-3.1
cat > "$W/recipe-tool.sh" <<'REC'
NAME=tool
VERSION=3.1
TARBALL='tool-[0-9]*.tar.*'
SUMMARY="a tiny test tool"
DEPENDS=(hello)
build()   { make; }
package() { make DESTDIR="$PKGDIR" install; }
REC
NPSKG_SOURCES="$W/sources" NPSKG_WORK="$W/work" "$NP" --out "$W/pkgs" build "$W/recipe-tool.sh" > "$W/out" 2>&1
check "build produces a .npskg" test -f "$W/pkgs/tool-3.1.npskg"
check "default build removes its workspace" test -z "$(find "$W/work" -mindepth 1 -maxdepth 1 -type d -name 'build.*' -print -quit)"

# Opt-in preservation after a successful build.
NPSKG_SOURCES="$W/sources" NPSKG_WORK="$W/work-keep" NPSKG_KEEP_BUILD=1 "$NP" --out "$W/pkgs" build "$W/recipe-tool.sh" > "$W/out" 2>&1
said "keeping build directory:" "successful build reports its preserved workspace"
KEEP_SUCCESS=$(find "$W/work-keep" -mindepth 1 -maxdepth 1 -type d -name 'build.*' -print -quit)
check "successful build workspace is preserved" test -d "$KEEP_SUCCESS"
check "preserved workspace contains staged files" test -d "$KEEP_SUCCESS/stage"

# Opt-in preservation after a failed build.
cat > "$W/recipe-fail.sh" <<'REC'
NAME=broken
VERSION=1
build() { echo "failure marker" > build-marker; return 1; }
package() { :; }
REC
refuse "a deliberately failing build exits non-zero" env NPSKG_SOURCES="$W/sources" NPSKG_WORK="$W/work-fail" NPSKG_KEEP_BUILD=1 "$NP" --out "$W/pkgs" build "$W/recipe-fail.sh"
said "keeping build directory:" "failed build reports its preserved workspace"
KEEP_FAIL=$(find "$W/work-fail" -mindepth 1 -maxdepth 1 -type d -name 'build.*' -print -quit)
check "failed build workspace is preserved" test -d "$KEEP_FAIL"
check "failed build marker survives" test -f "$KEEP_FAIL/src/build-marker"

refuse "invalid NPSKG_KEEP_BUILD value is rejected" env NPSKG_KEEP_BUILD=maybe "$NP" list
newroot n; RN=$(R n); "$NP" --root "$RN" install "$W/pkgs/hello-1.0.npskg" >/dev/null 2>&1
check "built package installs (its dependency is present)" "$NP" --root "$RN" install "$W/pkgs/tool-3.1.npskg"
check "built package verifies" "$NP" --root "$RN" verify tool
"$NP" --root "$RN" info tool > "$W/out"; said "Depends: hello" "recipe DEPENDS ended up in META"
said "Summary: a tiny test tool" "recipe SUMMARY ended up in META"
check "the built program is the one from the tarball" grep -q "built" "$RN/usr/bin/tool"
printf 'NAME=bad\nVERSION=1\nbuild() { :; }\n' > "$W/recipe-bad.sh"
refuse "a recipe without package() is refused" env NPSKG_SOURCES="$W/sources" NPSKG_WORK="$W/work" "$NP" --out "$W/pkgs" build "$W/recipe-bad.sh"
check "the build left no work directory behind" test -z "$(ls -A "$W/work" 2>/dev/null)"

echo
echo "npskg tests: $pass passed, $failn failed"
[ "$failn" -eq 0 ]
