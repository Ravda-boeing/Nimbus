# Package manager design (Phase 2) - DRAFT

Status: a first draft for Rav to react to. Nothing here is built yet. Items
marked **DECISION** are yours to make; the recommendation is mine.

## Why Phase 2 matters

Phase 1 builds the base system the LFS way: each package is compiled and
installed with `make install`, and nothing remembers which file came from where.
That is fine for a bootstrap and a problem for a real distro: you cannot cleanly
remove or upgrade anything, and you cannot ask "which package owns this file?".
Phase 2 adds that memory.

## What exists today

- `packages/nimbus-tools-0.3.npskg/` is the *source layout* of one package: a
  `META` file (Name, Version, Architecture, Summary, Maintainer, License,
  Depends, Conflicts, Provides, Replaces, Files) and empty `preinst`, `postinst`,
  `prerm`, `postrm` scripts. It is modelled on Debian-style control data.
- `tools/phase1/recipes/` holds one build recipe per package: `TARBALL='...'` and
  a `build()` function that ends in `make DESTDIR="$LFS" install`.

## Two separate things

1. A **recipe** says how to build software from source (already exists).
2. A **package** (`.npskg` file) is the built result: the files to install, plus
   metadata. A recipe produces a package; a package never needs the compiler.

The key change: instead of installing straight into the target
(`DESTDIR=$LFS`), a recipe installs into a **staging directory**
(`DESTDIR=/some/stage`). The package tool archives the staging directory. This is
what makes "what files does this package own?" answerable.

## Package file (`.npskg`)

A tar archive (compression: see decisions) containing:

```
META          the existing key: value format, kept as is
FILES         generated: one line per file: path, type, mode, owner, sha256
SCRIPTS/      preinst postinst prerm postrm (optional, may be empty)
data/         the staged tree, as it will appear under /
```

Name: `<name>-<version>.npskg`, for example `xz-5.8.3-1.npskg` if a release
number is wanted. **Note:** today's `nimbus-tools-0.3.npskg` is a *directory*
(source layout). To avoid confusion, rename source directories to
`packages/<name>/` and keep the `.npskg` extension for built files only.

## Installed database

```
/var/lib/npskg/installed/<name>/META
/var/lib/npskg/installed/<name>/FILES
```

One directory per installed package; no other state. "What is installed" is
`ls`. "Who owns this file" is a search of the `FILES` lists. Easy to inspect,
easy to repair by hand.

## Commands (target set)

| Command | Does |
|---|---|
| `npskg build <recipe>` | build in a stage dir, write `<name>-<version>.npskg` |
| `npskg install <file>` | check, extract, record; supports `--root DIR` |
| `npskg remove <name>` | delete exactly the files in its `FILES` list |
| `npskg list` / `files <name>` | what is installed / what a package owns |
| `npskg owns <path>` | which package owns a file |
| `npskg verify <name>` | compare installed files with the recorded hashes |

`--root DIR` is essential for Nimbus: it lets us install into `/mnt/lfs`, into a
chroot, or into a disk image for the installer, without being inside that system.

## Install and remove: safety rules

- Take a lock; two runs at once must not be possible.
- Install: refuse if a dependency is missing, if a file is owned by another
  package (unless `Replaces` allows it), or if the archive has a path that is
  absolute-outside-root or contains `..`. Extract to a temporary place first,
  move into place, and write the `FILES` record **last**, so a failed install
  leaves no false ownership.
- Remove: delete only paths listed in the package's `FILES`, only under the
  root, never a directory that still has other files, never `/`. Refuse if
  another installed package depends on it.
- Config files that the user may edit (`Conffiles` list in `META`): do not
  overwrite or delete a modified one on upgrade or remove. Can wait for v2.

## Dependencies

Keep the existing fields: `Depends` (with optional version constraints),
`Conflicts`, `Provides`, `Replaces`. First version: **check only**. Refuse to
install with a missing dependency and refuse to remove something that is
depended on; do not try to resolve and fetch automatically yet. An automatic
resolver comes with a repository (later).

## Recipe format v2 (backward compatible)

Today's recipes keep working. New optional fields add what a package needs:

```bash
NAME=xz
VERSION=5.8.3
TARBALL='xz-[0-9]*.tar.*'
DEPENDS=(glibc)

build() {            # unchanged: configure and make
    ./configure --prefix=/usr ...
    make
}
package() {          # new: install into the stage dir that npskg provides
    make DESTDIR="$PKGDIR" install
}
```

Phase 1 recipes call `make DESTDIR="$LFS" install` inside `build()`. For Phase 2
the install step moves to `package()`, so the same commands can target a stage
dir. This is a small mechanical change per recipe.

## Bootstrapping: when to start tracking (the important decision)

The LFS system is built twice over, in a sense: chapters 5 to 7 build
**temporary** tools that chapter 8 replaces. Only chapter 8 produces the files
that stay. So:

- **Recommended:** write a small `npskg` (core commands only) **between chapter
  7 and chapter 8**, then build every chapter 8 package through it. The final
  system is tracked from its first file, and the temporary tools never need to be
  packaged.
- Alternative: finish chapter 8 the book's way, then rebuild everything into
  packages afterwards. More work, and nothing is tracked in the meantime.

The tool must run inside the chroot, so it has to work with what chapter 7 has
installed: Bash, Coreutils, Tar, Xz, Gzip, Sed, Grep, Gawk, Findutils, and (after
chapter 7) Perl and Python. That points to the language decision below.

## Decisions (yours)

1. **Implementation language.** *Recommend: Bash first.* It runs in the chroot
   with no extra build, it matches everything written so far, and a prototype is
   quick to test. Python is available after chapter 7 and gives easier data
   handling; C or Rust give speed and safety but a bigger build before you can use
   it. Rewriting later is an option once the design has settled.
2. **Archive compression.** *Recommend: xz* (already in the base system; zstd
   would need an extra package early). Revisit when speed matters.
3. **When to start tracking.** *Recommend: before chapter 8* (see above).
4. **Dependency scope for v1.** *Recommend: check only, no resolver.*
5. **Config file handling.** *Recommend: leave for v2.*
6. **Repository, index and package signing.** *Recommend: later*, after the core
   works. Needed before Nimbus has an installer or an update mechanism.

## Milestones

1. `npskg build`: stage, generate `FILES`, write the archive. Test with one small
   package.
2. `npskg install` and `remove` into a `--root`, with the safety rules above.
3. `list`, `files`, `owns`, `verify`.
4. Dependency checks.
5. Use it for chapter 8.
6. Repository and upgrades.
